//
// hooker.h
// libdycall
//
// Created by SeanIsNotAConstant on 15.10.24
//

#ifndef HOOKER_H
#define HOOKER_H

/**
 * @brief Set up the hooks
 *
 * This function hooks certain symbols like exit and atexit to make a dylib behave like a binariy
 * For example instead of calling real exit it would call our own implementation of it
 */
int hooker(void);

/**
 * @brief Remove the hooks.
 *
 * When your done with your actions id recommend you to call unhooker() in order to make your process
 * behave normally again
 *
 */
int unhooker(void);

#endif // HOOKER_H
