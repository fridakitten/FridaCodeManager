// exithooker.c
//
// Created by SeanIsNotAConstant on 15.10.24
//

// hooker to make it behave like a usual binarie!

#include <stdio.h>
#include "fishhook.h"

typedef void (*rexit)(int);
typedef void (*ratexit)(void);

static void (*original_exit)(int) = NULL;
static void (*original_uexit)(void) = NULL;
static int (*original_atexit)(void (*func)()) = NULL;
static int (*original_uatexit)(void (*func)()) = NULL;

extern void dy_exit(int status);
extern int dy_atexit(void (*func)());

void hooker(void)
{
    printf("[hookexit] thank you facebook for fishhook <3\n");

    struct rebinding rebind_exit;
    rebind_exit.name = "exit";
    rebind_exit.replacement = dy_exit;
    rebind_exit.replaced = (void**)&original_exit;
    printf("[hookexit] exit hooked\n");

    struct rebinding rebind_uexit;
    rebind_uexit.name = "_exit";
    rebind_uexit.replacement = dy_exit;
    rebind_uexit.replaced = (void**)&original_uexit;
    printf("[hookexit] _exit hooked\n");

    struct rebinding rebind_atexit;
    rebind_atexit.name = "atexit";
    rebind_atexit.replacement = dy_atexit;
    rebind_atexit.replaced = (void**)&original_atexit;
    printf("[hookexit] atexit hooked\n");

    struct rebinding rebind_uatexit;
    rebind_uatexit.name = "_atexit";
    rebind_uatexit.replacement = dy_atexit;
    rebind_uatexit.replaced = (void**)&original_uatexit;
    printf("[hookexit] _atexit hooked\n");

    struct rebinding rebindings[] = {
        rebind_exit,
        rebind_uexit,
        rebind_atexit,
        rebind_uatexit
    };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
    return;
}

void unhooker(void)
{
    struct rebinding rebind_exit;
    rebind_exit.name = "exit";
    rebind_exit.replacement = original_exit;
    rebind_exit.replaced = (void**)&original_exit;

    struct rebinding rebind_uexit;
    rebind_uexit.name = "_exit";
    rebind_uexit.replacement = original_uexit;
    rebind_uexit.replaced = (void**)&original_uexit;

    struct rebinding rebind_atexit;
    rebind_atexit.name = "atexit";
    rebind_atexit.replacement = original_atexit;
    rebind_atexit.replaced = (void**)&original_atexit;

    struct rebinding rebind_uatexit;
    rebind_uatexit.name = "_atexit";
    rebind_uatexit.replacement = original_uatexit;
    rebind_uatexit.replaced = (void**)&original_uatexit;

    struct rebinding rebindings[] = {
        rebind_exit,
        rebind_uexit,
        rebind_atexit,
        rebind_uatexit
    };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));

    printf("[hookexit] hooks removed\n");
    return;
}
