//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#define _POSIX_C_SOURCE 200809L  // Ensure we get POSIX.1-2008 definitions

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <dirent.h>

void remove_directory(const char *path, bool verbose, bool interactive, bool parents) {
    struct stat st;

    // Check if the directory exists
    if (stat(path, &st) == -1) {
        perror("stat");
        exit(EXIT_FAILURE);
    }

    if (!S_ISDIR(st.st_mode)) {
        fprintf(stderr, "'%s' is not a directory\n", path);
        exit(EXIT_FAILURE);
    }

    if (verbose) {
        printf("Removing directory: %s\n", path);
    }

    if (interactive) {
        char response;
        printf("Remove directory '%s'? (y/n): ", path);
        fflush(stdout);
        scanf(" %c", &response);
        if (response != 'y' && response != 'Y') {
            printf("Not removing directory '%s'\n", path);
            return;
        }
    }

    // Remove directory
    if (parents) {
        // Recursive removal using opendir(), readdir() and remove_directory()
        DIR *dir = opendir(path);
        if (!dir) {
            perror("opendir");
            exit(EXIT_FAILURE);
        }

        struct dirent *entry;
        while ((entry = readdir(dir)) != NULL) {
            if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
                continue;
            }

            char *child_path = (char *)malloc(strlen(path) + strlen(entry->d_name) + 2);
            sprintf(child_path, "%s/%s", path, entry->d_name);
            remove_directory(child_path, verbose, interactive, parents);
            free(child_path);
        }

        closedir(dir);

        // Now remove the current directory itself
        if (rmdir(path) == -1) {
            perror("rmdir");
            exit(EXIT_FAILURE);
        }
    } else {
        // Non-recursive removal
        if (rmdir(path) == -1) {
            perror("rmdir");
            exit(EXIT_FAILURE);
        }
    }

    if (verbose) {
        printf("Directory '%s' removed successfully\n", path);
    }
}

int main(int argc, char *argv[]) {
    int opt;
    bool verbose = false;
    bool interactive = false;
    bool parents = false;

    while ((opt = getopt(argc, argv, "pvi")) != -1) {
        switch (opt) {
            case 'p':
                parents = true;
                break;
            case 'v':
                verbose = true;
                break;
            case 'i':
                interactive = true;
                break;
            default:
                fprintf(stderr, "Usage: %s [-p] [-v] [-i] directory...\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    if (optind >= argc) {
        fprintf(stderr, "Missing directory operand\n");
        fprintf(stderr, "Try '%s --help' for more information.\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    for (int i = optind; i < argc; i++) {
        remove_directory(argv[i], verbose, interactive, parents);
    }

    return EXIT_SUCCESS;
}