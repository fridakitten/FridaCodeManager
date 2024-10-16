#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

typedef void (*atexit_func)(void);

atexit_func registered_func = NULL;

void dy_atexit(atexit_func func) {
    registered_func = func;
}

void dy_exit(int status) {

    if (registered_func) {
        registered_func();
    }

    pthread_exit((void*)(intptr_t)status);
}
