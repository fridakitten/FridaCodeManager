//
// exithooker.c
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include "fishhook.h"

static void (*original_exit)(int);
static void (*original_uexit)(int);

extern void dy_exit(int status);

int hookexit(void *handel) {
    printf("[hookexit] thank you facebook for fishhook <3\n");

    struct rebinding rebind_exit;
    rebind_exit.name = "exit";
    rebind_exit.replacement = dy_exit;
    rebind_exit.replaced = (void**)&original_exit;
    printf("[hookexit] exit hooked\n");

    struct rebinding rebind_uexit;
    rebind_uexit.name = "_exit";
    rebind_uexit.replacement = dy_exit;
    rebind_uexit.replaced = (void **)&original_uexit;
    printf("[hookexit] _exit hooked\n");

    struct rebinding rebindings[] = { rebind_exit, rebind_uexit };
    rebind_symbols(rebindings, 1);
    return 0;
}