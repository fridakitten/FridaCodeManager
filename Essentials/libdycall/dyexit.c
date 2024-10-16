//
// exithook.c
//
// Created by SeanIsNotAConstant on 15.10.24
//

#include <stdio.h>
#include <pthread.h>
 
//hooked exit function
void dy_exit(int status) {
    //ToDo: implement handling for atexit
    /*if (__libc_atexit) {
        __libc_atexit();
    }*/

    fflush(NULL);

    pthread_exit(NULL);
}