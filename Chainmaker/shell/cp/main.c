//
// main.c
//
// Created by SeanIsNotAConstant on 25.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <limits.h>

#define BUFFER_SIZE 1024

int copy_file(const char *source, const char *destination, int preserve);
int copy_directory(const char *source, const char *destination, int preserve, int interactive);

int main(int argc, char *argv[]) {
    int opt;
    int preserve = 0;   // Flag for preserving file attributes
    int interactive = 0; // Flag for interactive mode
    int recursive = 0;  // Flag for recursive mode

    // Parse options
    while ((opt = getopt(argc, argv, "ipr")) != -1) {
        switch (opt) {
            case 'i':
                interactive = 1;
                break;
            case 'p':
                preserve = 1;
                break;
            case 'r':
                recursive = 1;
                break;
            default:
                fprintf(stderr, "Usage: %s [-ipr] source destination\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    // Check remaining arguments
    if (optind + 2 != argc) {
        fprintf(stderr, "Usage: %s [-ipr] source destination\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *source = argv[optind];
    const char *destination = argv[optind + 1];

    // Check if source is a regular file or directory
    struct stat src_stat;
    if (stat(source, &src_stat) == -1) {
        perror("Error getting file status");
        exit(EXIT_FAILURE);
    }

    // Handle directory copying if recursive flag is set
    if (S_ISDIR(src_stat.st_mode)) {
        if (!recursive) {
            fprintf(stderr, "Omitting directory '%s', use -r to copy directories.\n", source);
            exit(EXIT_FAILURE);
        }
        copy_directory(source, destination, preserve, interactive);
    } else {
        copy_file(source, destination, preserve);
    }

    printf("File(s) copied successfully.\n");
    return 0;
}

int copy_file(const char *source, const char *destination, int preserve) {
    FILE *src, *dest;
    char buffer[BUFFER_SIZE];
    size_t bytes_read;

    // Open source file
    if ((src = fopen(source, "rb")) == NULL) {
        perror("Error opening source file");
        return -1;
    }

    // Open destination file
    if ((dest = fopen(destination, "wb")) == NULL) {
        perror("Error opening destination file");
        fclose(src);
        return -1;
    }

    // Copy file contents
    while ((bytes_read = fread(buffer, 1, BUFFER_SIZE, src)) > 0) {
        fwrite(buffer, 1, bytes_read, dest);
    }

    // Close files
    fclose(src);
    fclose(dest);

    // Preserve file attributes if requested
    if (preserve) {
        struct stat src_stat;
        if (stat(source, &src_stat) == -1) {
            perror("Error getting file status");
            return -1;
        }

        if (chmod(destination, src_stat.st_mode) == -1) {
            perror("Error preserving file permissions");
            return -1;
        }
    }

    return 0;
}

int copy_directory(const char *source, const char *destination, int preserve, int interactive) {
    DIR *dir;
    struct dirent *entry;

    // Create destination directory if it doesn't exist
    struct stat dest_stat;
    if (stat(destination, &dest_stat) == -1) {
        if (mkdir(destination, 0777) == -1) {
            perror("Error creating destination directory");
            exit(EXIT_FAILURE);
        }
    }

    // Open source directory
    if ((dir = opendir(source)) == NULL) {
        perror("Error opening source directory");
        return -1;
    }

    // Traverse directory entries
    while ((entry = readdir(dir)) != NULL) {
        // Skip "." and ".." entries
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        // Construct full path of the source and destination
        char src_path[PATH_MAX];
        char dest_path[PATH_MAX];
        snprintf(src_path, PATH_MAX, "%s/%s", source, entry->d_name);
        snprintf(dest_path, PATH_MAX, "%s/%s", destination, entry->d_name);

        struct stat src_stat;
        if (stat(src_path, &src_stat) == -1) {
            perror("Error getting file status");
            return -1;
        }

        if (S_ISDIR(src_stat.st_mode)) {
            // Recursive copy for directories
            copy_directory(src_path, dest_path, preserve, interactive);
        } else {
            // Copy file
            if (interactive) {
                // Interactive mode: prompt before overwriting
                printf("Overwrite %s? (y/n): ", dest_path);
                char response;
                scanf(" %c", &response);
                if (response != 'y' && response != 'Y') {
                    continue;  // Skip copying this file
                }
            }
            copy_file(src_path, dest_path, preserve);
        }
    }

    // Close directory
    closedir(dir);
    return 0;
}