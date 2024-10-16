//
// exithooker.c
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include <stdio.h>
#include "fishhook.h"

extern void dy_exit(int status);

int hookexit() {
    //thank you facebook

    //preparing to hook exit
    struct rebinding rebind_exit;
    rebind_exit.name = "exit";
    rebind_exit.replacement = dy_exit;

    //hooking exit
    struct rebinding rebindings[] = { rebind_exit };
    rebind_symbols(rebindings, 1);
    return 0;
}