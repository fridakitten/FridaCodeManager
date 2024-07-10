//
// main.c
//
// Created by SeanIsNotAConstant on 25.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

void print_usage() {
    fprintf(stderr, "Usage: ln [-s] <source> <destination>\n");
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
    int symbolic = 0;  // Flag for symbolic link
    char *source, *destination;

    // Parse command line arguments
    if (argc < 3 || argc > 4) {
        print_usage();
    }

    // Check for symbolic link option
    if (argc == 4 && strcmp(argv[1], "-s") == 0) {
        symbolic = 1;
        source = argv[2];
        destination = argv[3];
    } else {
        source = argv[1];
        destination = argv[2];
    }

    // Create link
    if (symbolic) {
        if (symlink(source, destination) == -1) {
            perror("symlink");
            exit(EXIT_FAILURE);
        }
    } else {
        if (link(source, destination) == -1) {
            perror("link");
            exit(EXIT_FAILURE);
        }
    }

    return EXIT_SUCCESS;
}