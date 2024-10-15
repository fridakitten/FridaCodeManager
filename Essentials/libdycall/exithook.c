//
// exithook.c
//
// Created by SeanIsNotAConstant on 15.10.24
//

#include <stdio.h>
#include <pthread.h>
 
//fuckoff hook
void dy_exit(int status) {
    printf("[fakeexit] ending thread\n");
    pthread_exit(NULL);
}