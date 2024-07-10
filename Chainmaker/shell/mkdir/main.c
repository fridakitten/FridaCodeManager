//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

void create_directory(const char *path, mode_t mode, int verbose) {
    if (mkdir(path, mode) == 0) {
        if (verbose) {
            printf("mkdir: created directory '%s'\n", path);
        }
    } else {
        fprintf(stderr, "mkdir: cannot create directory '%s': %s\n", path, strerror(errno));
    }
}

int main(int argc, char *argv[]) {
    int p_flag = 0;
    int m_flag = 0;
    int v_flag = 0;
    mode_t mode = 0777;  // Default mode (rwxrwxrwx)

    // Parse command-line arguments
    int opt;
    while ((opt = getopt(argc, argv, "pm:v")) != -1) {
        switch (opt) {
            case 'p':
                p_flag = 1;
                break;
            case 'm':
                m_flag = 1;
                mode = strtol(optarg, NULL, 8); // Convert octal string to mode_t
                break;
            case 'v':
                v_flag = 1;
                break;
            default:
                fprintf(stderr, "Usage: %s [-p] [-m mode] [-v] directory...\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    // Create directories
    for (int i = optind; i < argc; i++) {
        if (p_flag) {
            char *path = argv[i];
            char *slash = strrchr(path, '/');
            if (slash != NULL) {
                *slash = '\0';  // Temporarily truncate path
                if (mkdir(argv[i], mode) == -1 && errno != EEXIST) {
                    fprintf(stderr, "mkdir: cannot create directory '%s': %s\n", argv[i], strerror(errno));
                    continue;
                }
                *slash = '/';  // Restore path
            }
        } else {
            create_directory(argv[i], mode, v_flag);
        }
    }

    return EXIT_SUCCESS;
}