#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

//avoid dylocking twice!
void *handle;

/**
 * @brief This function is to lock a certain dybinary or dylib to be dlclosed
 *
 */
void dyunlock()
{
    dlclose(handle);
    handle = NULL;
}

/**
 * @brief This function is to unlock a with dylock() locked dylib
 *
 */
void dylock(NSString *dylibPath)
{
    if(handle == NULL) {
        handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    } else {
        dyunlock();
        handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    }
}
