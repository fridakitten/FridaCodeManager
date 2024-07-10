//
// cwdtopwd.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int setpwd() {
    char cwd[1024];  // Buffer to hold the current working directory path

    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        // Successfully got the current working directory
        if (setenv("PWD", cwd, 1) != 0) {
            perror("setenv");
            return 1;  // Return error if setenv fails
        }
        return 0;  // Return success
    } else {
        // Error in getting current working directory
        perror("getcwd");
        return 1;  // Return error
    }
}

int setcwd() {
    char *pwd = getenv("PWD");

    if (pwd == NULL) {
        fprintf(stderr, "PWD environment variable is not set.\n");
        return 1;
    }

    if (chdir(pwd) != 0) {
        perror("chdir");
        return 1;  // Return error if chdir fails
    }

    return 0;  // Return success
}

int sethomecwd() {
    char *pwd = getenv("HOME");

    if (pwd == NULL) {
        fprintf(stderr, "PWD environment variable is not set.\n");
        return 1;
    }

    if (chdir(pwd) != 0) {
        perror("chdir");
        return 1;  // Return error if chdir fails
    }

    return 0;  // Return success
}