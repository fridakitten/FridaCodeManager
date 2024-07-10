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
#include <dirent.h>
#include <sys/stat.h>

void remove_file(const char *path, bool verbose, bool interactive) {
    if (unlink(path) == -1) {
        perror("unlink");
        exit(EXIT_FAILURE);
    }

    if (verbose) {
        printf("Removed file: %s\n", path);
    }
}

void remove_directory(const char *path, bool verbose, bool interactive, bool recursive) {
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

        struct stat st;
        if (lstat(child_path, &st) == -1) {
            perror("lstat");
            free(child_path);
            closedir(dir);
            exit(EXIT_FAILURE);
        }

        if (S_ISDIR(st.st_mode)) {
            if (recursive) {
                remove_directory(child_path, verbose, interactive, recursive);
            } else {
                fprintf(stderr, "rm: cannot remove '%s': Is a directory\n", child_path);
            }
        } else {
            remove_file(child_path, verbose, interactive);
        }

        free(child_path);
    }

    closedir(dir);

    if (rmdir(path) == -1) {
        perror("rmdir");
        exit(EXIT_FAILURE);
    }

    if (verbose) {
        printf("Removed directory: %s\n", path);
    }
}

void remove_entry(const char *path, bool verbose, bool interactive, bool recursive) {
    struct stat st;
    if (lstat(path, &st) == -1) {
        perror("lstat");
        exit(EXIT_FAILURE);
    }

    if (S_ISDIR(st.st_mode)) {
        remove_directory(path, verbose, interactive, recursive);
    } else {
        remove_file(path, verbose, interactive);
    }
}

int main(int argc, char *argv[]) {
    int opt;
    bool recursive = false;
    bool force = false;
    bool interactive = false;
    bool verbose = false;

    while ((opt = getopt(argc, argv, "rfiv")) != -1) {
        switch (opt) {
            case 'r':
                recursive = true;
                break;
            case 'f':
                force = true;
                break;
            case 'i':
                interactive = true;
                break;
            case 'v':
                verbose = true;
                break;
            default:
                fprintf(stderr, "Usage: %s [-rRfiv] file...\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    if (optind >= argc) {
        fprintf(stderr, "Missing file operand\n");
        fprintf(stderr, "Try '%s --help' for more information.\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    for (int i = optind; i < argc; i++) {
        remove_entry(argv[i], verbose, interactive, recursive);
    }

    return EXIT_SUCCESS;
}