//
// exithook.c
//
// Created by SeanIsNotAConstant on 15.10.24
//

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <unistd.h>
#include <pthread.h>

jmp_buf buffer;
 
//fuckoff hook
void dy_exit(int status) {
    printf("[fakeexit] locked up: %d\n[fakeexit] jumping back to thread state checker\n", status);
    longjmp(buffer, 1);
}