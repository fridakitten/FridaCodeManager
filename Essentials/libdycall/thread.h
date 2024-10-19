//
// thread.h
// libdycall
//
// Created by SeanIsNotAConstant on 15.10.24
//

#ifndef THREAD_H
#define THREAD_H

/**
 * @brief This Struct holds the args of the threadripper
 */
typedef struct {
    void *handle;
    char **argv;
    int argc;
} dyargs;

/**
 * @brief This function seperates the main symbol behaviour of the dybinary and the binary
 *
 * We use this as a exitloop bypass
 */
void *threadripper(void *arg);

#endif // THREAD_H
