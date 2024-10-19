//
// hooker.c
// libdycall
//
// Created by SeanIsNotAConstant on 15.10.24
//

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

/**
 * @brief Set up the hooks
 *
 * This function hooks certain symbols like exit and atexit to make a dylib behave like a binariy
 * For example instead of calling real exit it would call our own implementation of it
 */
int hooker(void)
{
    struct rebinding rebind_exit = {
        .name = "exit",
        .replacement = dy_exit,
        .replaced = (void**)&original_exit
    };

    struct rebinding rebind_uexit = {
        .name = "_exit",
        .replacement = dy_exit,
        .replaced = (void**)&original_uexit
    };

    struct rebinding rebind_atexit = {
        .name = "atexit",
        .replacement = dy_atexit,
        .replaced = (void**)&original_atexit
    };

    struct rebinding rebind_uatexit = {
        .name = "_atexit",
        .replacement = dy_atexit,
        .replaced = (void**)&original_uatexit
    };

    struct rebinding rebindings[] = {
        rebind_exit,
        rebind_uexit,
        rebind_atexit,
        rebind_uatexit
    };

    return rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
}

/**
 * @brief Remove the hooks.
 *
 * When your done with your actions id recommend you to call unhooker() in order to make your process
 * behave normally again
 *
 */
int unhooker(void)
{
    struct rebinding unbind_exit = {
        .name = "exit",
        .replacement = original_exit,
        .replaced = (void**)&original_exit
    };

    struct rebinding unbind_uexit = {
        .name = "_exit",
        .replacement = original_uexit,
        .replaced = (void**)&original_uexit
    };

    struct rebinding unbind_atexit = {
        .name = "atexit",
        .replacement = original_atexit,
        .replaced = (void**)&original_atexit
    };

    struct rebinding unbind_uatexit = {
        .name = "_atexit",
        .replacement = original_uatexit,
        .replaced = (void**)&original_uatexit
    };

    struct rebinding rebindings[] = {
        unbind_exit,
        unbind_uexit,
        unbind_atexit,
        unbind_uatexit
    };

    return rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
}
