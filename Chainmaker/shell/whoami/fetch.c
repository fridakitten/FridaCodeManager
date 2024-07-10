//
// fetch.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <unistd.h>
#include <pwd.h>
#include <strings.h>

char* getuser() {
    uid_t uid = geteuid();
    
    struct passwd *pw = getpwuid(uid);
    if (pw == NULL) {
        perror("getpwuid");
        return NULL;
    }
    
    return strdup(pw->pw_name);
}