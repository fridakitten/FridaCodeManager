//
// main.c
//
// Created by SeanIsNotAConstant on 09.07.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

const char* getpwdfile(void) {
    char *container = getenv("ROOT");

    if (container == NULL) {
        fprintf(stderr, "Error: ROOT environment variable is not set\n");
        exit(1);
    }

    // Allocate memory for the full path
    char *path = malloc(strlen(container) + strlen("/sshdog/config/password") + 1);
    if (path == NULL) {
        perror("Error allocating memory for path\n");
        exit(1);
    }

    sprintf(path, "%s/sshdog/config/password", container);

    return (const char*)path;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <new_password>\n", argv[0]);
        return 1;
    }

    if (getuid() == 0) {
        const char *pwdfile = getpwdfile();
        FILE *file = fopen(pwdfile, "w");

        if (file == NULL) {
            perror("Error opening file");
            free((void*)pwdfile);
            return 1;
        }

        if (fprintf(file, "%s", (const char*)argv[1]) < 0) {
            perror("Error writing to file");
            fclose(file);
            free((void*)pwdfile);
            return 1;
        }

        fclose(file);
        free((void*)pwdfile);

        printf("Password changed successfully\n");
    } else {
        printf("Permission denied, you are not root\n");
    }
    return 0;
}