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
int lock = 0;
 
//fuckoff hook
void dy_exit(int status) {
    printf("[fakeexit] locked up: %d\n[fakeexit] jumping back to thread state checker\n", status);
    lock = 1;
    longjmp(buffer, 0);
}