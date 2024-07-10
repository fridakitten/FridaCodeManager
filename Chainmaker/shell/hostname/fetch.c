//
// fetch.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <unistd.h>
#include <pwd.h>
#include <strings.h>

#define HOST_NAME_MAX 255

char* gethost() {
    static char hostname[HOST_NAME_MAX];
    if (gethostname(hostname, HOST_NAME_MAX) == 0) {
        return hostname;
    } else {
        return NULL;
    }
}