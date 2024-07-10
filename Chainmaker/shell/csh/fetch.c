//
// user.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <unistd.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* getuser() {
    uid_t uid = geteuid();  // Get effective user ID
    
    struct passwd *pw = getpwuid(uid);
    if (pw == NULL) {
        perror("getpwuid");
        return NULL;
    }
    
    return strdup(pw->pw_name);  // Duplicate and return username
}

char* getpwd() {
    char* pwd = getenv("PWD");
    if (pwd == NULL) {
        perror("getenv");
        return NULL;
    }
    return pwd;
}

char* gethost() {
    char *hostname = NULL;
    size_t size = 256;  // Initial buffer size assumption

    while (1) {
        hostname = (char*)malloc(size);
        if (hostname == NULL) {
            perror("malloc");
            return NULL;  // Return NULL if malloc fails
        }

        if (gethostname(hostname, size) == 0) {
            // Successfully got the host name
            return hostname;
        } else {
            // Error in getting host name
            perror("gethostname");
            free(hostname);  // Free allocated memory on error
            return NULL;
        }

        // If the buffer was too small, retry with a larger buffer
        size *= 2;
        free(hostname);  // Free the current attempt before retrying
    }
}
