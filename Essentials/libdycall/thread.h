//
// threadripper.h
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include <dlfcn.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

typedef struct {
    void *handle;
    char **argv;
    int argc;
} dyargs;

void *threadripper(void *arg);