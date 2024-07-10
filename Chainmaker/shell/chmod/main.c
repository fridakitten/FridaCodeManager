//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>
#include <string.h>
#include <errno.h>
#include <limits.h>

void print_usage_and_exit() {
    fprintf(stderr, "Usage: ./chmod_extended <mode> <file>\n");
    fprintf(stderr, "       ./chmod_extended -R <mode> <directory>\n");
    fprintf(stderr, "Modes: \n");
    fprintf(stderr, "  Octal mode: 0755, 0644, etc.\n");
    fprintf(stderr, "  Symbolic mode: +x, -w, etc.\n");
    exit(EXIT_FAILURE);
}

void apply_chmod(const char *mode, const char *path, int recursive) {
    struct stat st;
    if (stat(path, &st) == -1) {
        perror("stat");
        exit(EXIT_FAILURE);
    }

    if (recursive && S_ISDIR(st.st_mode)) {
        // Apply recursively to directory and its contents
        printf("Recursively changing permissions of directory '%s' to '%s'\n", path, mode);
        if (chmod(path, strtol(mode, 0, 8)) == -1) {
            perror("chmod");
            exit(EXIT_FAILURE);
        }

        DIR *dir = opendir(path);
        if (dir == NULL) {
            perror("opendir");
            exit(EXIT_FAILURE);
        }

        struct dirent *entry;
        while ((entry = readdir(dir)) != NULL) {
            if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
                continue;
            }

            char new_path[PATH_MAX];
            snprintf(new_path, sizeof(new_path), "%s/%s", path, entry->d_name);
            apply_chmod(mode, new_path, 1); // Recursive call
        }

        closedir(dir);
    } else {
        // Apply chmod to a single file or non-recursive directory
        printf("Changing permissions of '%s' to '%s'\n", path, mode);
        if (chmod(path, strtol(mode, 0, 8)) == -1) {
            perror("chmod");
            exit(EXIT_FAILURE);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3 || (argc == 3 && argv[1][0] == '-')) {
        print_usage_and_exit();
    }

    int recursive = 0;
    int start_index = 1;

    if (argv[1][0] == '-' && argv[1][1] == 'R' && argc >= 4) {
        recursive = 1;
        start_index = 2;
    }

    const char *mode = argv[start_index];
    const char *path = argv[start_index + 1];

    apply_chmod(mode, path, recursive);

    return EXIT_SUCCESS;
}