#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

/**
 * @brief This function holds the function pointer specified by a dybinary using atexit()
 *
 */
typedef void (*atexit_func)(void);
atexit_func registered_func = NULL;

/**
 * @brief This function is not meant to be called. Its our own implementation of the function for our hooker
 *
 */
void dy_atexit(atexit_func func)
{
    registered_func = func;
}

/**
 * @brief This function is not meant to be called. Its our own implementation of the function for our hooker
 *
 */
void dy_exit(int status)
{
    if (registered_func) {
        registered_func();
    }

    pthread_exit((void*)(intptr_t)status);
}
