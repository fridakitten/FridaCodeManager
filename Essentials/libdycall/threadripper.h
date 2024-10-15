//
// threadripper.h
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <setjmp.h>
#include <pthread.h>
#include <unistd.h>

typedef struct {
    void *handle;
    char **argv;
    int argc;
} dyargs;

void *threadripper(void *arg);