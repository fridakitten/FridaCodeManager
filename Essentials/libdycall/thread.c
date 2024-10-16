//
// threadripper.c
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include "thread.h"

void *threadripper(void *arg) {
    dyargs *data = (dyargs *)arg;
    void *handle = data->handle;

    int (*dylib_main)(int, char**) = dlsym(handle, "main");
    char *error = dlerror();
    if (error != NULL) {
        fprintf(stderr, "[dyexec] error: %s\n", error);
        pthread_exit(NULL);
        return NULL;
    }

    int status = dylib_main(data->argc, data->argv);

    pthread_exit((void*)(intptr_t)status);
    return NULL;
}
