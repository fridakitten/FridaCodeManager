//
// threadripper.c
//
// Created by SeanIsNotAConstant on 15.10.24
//

#include <dlfcn.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include "thread.h"

/**
 * @brief This function seperates the main symbol behaviour of the dybinary and the binary
 *
 * We use this as a exitloop bypass
 */
void *threadripper(void *arg)
{
    dyargs *data = (dyargs *)arg;
    void *handle = data->handle;

    int (*dylib_main)(int, char**) = dlsym(handle, "main");
    char *error = dlerror();
    if (error != NULL) {
        fprintf(stderr, "[!] error: %s\n", error);
        pthread_exit(NULL);
        return NULL;
    }

    int status = dylib_main(data->argc, data->argv);

    pthread_exit((void*)(intptr_t)status);
    return NULL;
}
