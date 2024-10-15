//
// dyexec.m
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <setjmp.h>

#include "fishhook.h"
#include "exithooker.h"
#include "threadripper.h"

extern jmp_buf buffer;
extern int lock;

int dyexec(NSString *dylibPath, NSString *arguments) {
    lock = 0;
    dyargs data;

    printf("[dyexec] dlopen: %s\n",[dylibPath UTF8String]);
    data.handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    if (!data.handle) {
        fprintf(stderr, "[dyexec] error: %s\n", dlerror());
        return -1;
    }
    printf("[dyexec] handle: %p\n",data.handle);

    dlerror();

    //exit hooking into dybinary
    printf("[dyexec] hooking\n");
    hookexit(data.handle);
    printf("[dyexec] hopefully done\n");
    //hook end

    //argv prepare
    NSArray<NSString *> *components = [arguments componentsSeparatedByString:@" "];
    data.argc = (int)[components count];
    data.argv = (char **)malloc((data.argc + 1) * sizeof(char *));
    for (int i = 0; i < data.argc; i++) {
        data.argv[i] = strdup([components[i] UTF8String]);
    }
    data.argv[data.argc] = NULL;
    
    //threadripper approach (exit loop bypass)
    pthread_t thread = data.thread;
    if (pthread_create(&thread, NULL, threadripper, (void *)&data) != 0) {
        fprintf(stderr, "Error creating thread\n");
        return 1;
    }
    sleep(1);
    pthread_join(thread, NULL);

    return 0;
}