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

#include "hooker.h"
#include "thread.h"

int hooked = 0;

int dyexec(NSString *dylibPath, NSString *arguments) {
    dyargs data;

    data.handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    if (!data.handle) {
        fprintf(stderr, "[dyexec] error: %s\n", dlerror());
        return -1;
    }

    dlerror();

    //exit hooking
    if(!hooked) {
        hookexit(data.handle);
        hooked = 1;
    }
    //done hooking

    //argv prepare
    NSArray<NSString *> *components = [arguments componentsSeparatedByString:@" "];
    data.argc = (int)[components count];
    data.argv = (char **)malloc((data.argc + 1) * sizeof(char *));
    for (int i = 0; i < data.argc; i++) {
        data.argv[i] = strdup([components[i] UTF8String]);
    }
    data.argv[data.argc] = NULL;
    
    //threadripper approach (exit loop bypass)
    pthread_t thread;
    if (pthread_create(&thread, NULL, threadripper, (void *)&data) != 0) {
        fprintf(stderr, "Error creating thread\n");
        return 1;
    }
    //oops we have to wait!!
    sleep(1);
    void *status;
    pthread_join(thread, &status);

    //if reference count wont hit 0 it wont free
    dlclose(data.handle);

    for (int i = 0; i < data.argc; i++) free(data.argv[i]);
    free(data.argv);

    return (intptr_t)status;
}
