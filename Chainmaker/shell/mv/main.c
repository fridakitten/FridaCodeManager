//
// main.c
//
// Created by SeanIsNotAConstant on 07.07.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void print_usage(const char *prog_name) {
    fprintf(stderr, "Usage: %s <source> <destination>\n", prog_name);
}

int main(int argc, char *argv[]) {
    // Check for the correct number of arguments
    if (argc != 3) {
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    const char *source = argv[1];
    const char *destination = argv[2];

    // Attempt to rename the file
    if (rename(source, destination) != 0) {
        perror("Error moving file");
        return EXIT_FAILURE;
    }

    printf("File moved successfully from %s to %s\n", source, destination);
    return EXIT_SUCCESS;
}