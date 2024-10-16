//
// exithooker.c
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include <stdio.h>
#include "fishhook.h"

extern void dy_exit(int status);
extern int dy_atexit(void (*func)());

int hookexit(void *handel) {
    printf("[hookexit] thank you facebook for fishhook <3\n");

    struct rebinding rebind_exit;
    rebind_exit.name = "exit";
    rebind_exit.replacement = dy_exit;
    printf("[hookexit] exit hooked\n");

    struct rebinding rebind_uexit;
    rebind_uexit.name = "_exit";
    rebind_uexit.replacement = dy_exit;
    printf("[hookexit] _exit hooked\n");

    struct rebinding rebind_atexit;
    rebind_atexit.name = "atexit";
    rebind_atexit.replacement = dy_atexit;
    printf("[hookexit] atexit hooked\n");

    struct rebinding rebind_uatexit;
    rebind_atexit.name = "_atexit";
    rebind_atexit.replacement = dy_atexit;
    printf("[hookexit] _atexit hooked\n");

    struct rebinding rebindings[] = { rebind_exit, rebind_uexit, rebind_atexit, rebind_uatexit };
    rebind_symbols(rebindings, 1);
    return 0;
}
