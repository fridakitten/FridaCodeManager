#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

//avoid dylocking twice!
void *handle;

void dyunlock() {
    dlclose(handle);
    handle = NULL;
}

void dylock(NSString *dylibPath) {
    if(handle == NULL) {
        handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    } else {
        printf("[dylock] warning unlocking previously locked dylock\n");
        dyunlock();
        handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    }
}