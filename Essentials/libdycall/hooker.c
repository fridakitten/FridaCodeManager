//
//  hooker.c
//  memory
//
//  Created by fridakitten on 30.10.24.
//

#include "fishhook.h"
#include <stdbool.h>
#include <stddef.h>
#include <malloc/malloc.h>

static bool isSpying = false;
static malloc_zone_t *zone;

static void* (*original_malloc)(size_t size) = NULL;
static void* (*original_calloc)(size_t num, size_t size) = NULL;
static void* (*original_realloc)(void *pointer, size_t size) = NULL;
static void (*original_free)(void *pointer) = NULL;

static void (*original_exit)(int) = NULL;
static int (*original_atexit)(void (*func)()) = NULL;

extern void dy_exit(int status);
extern int dy_atexit(void (*func)());

int hookerhelper(const char *victim, void *function, void **bunkerfunc)
{
    struct rebinding rebound =
    {
        .name = victim,
        .replacement = function,
        .replaced = (void**)bunkerfunc
    };

    struct rebinding rebindings[] =
    {
            rebound,
    };
    
    return rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
}

void* malloc_bind(size_t size)
{
    return malloc_zone_malloc(zone, size);
}

void* calloc_bind(size_t num, size_t size)
{
    return malloc_zone_calloc(zone, num, size);
}

void* realloc_bind(void *pointer, size_t size)
{
    return malloc_zone_realloc(zone, pointer, size);
}

void free_bind(void *pointer)
{
    malloc_zone_free(zone, pointer);
}

void unhooker(void)
{
    if(!isSpying)
    {
        zone = malloc_create_zone(0, 0);
        //hookerhelper("malloc", malloc_bind, (void**)&original_malloc);
        //hookerhelper("calloc", calloc_bind, (void**)&original_calloc);
        //hookerhelper("realloc", realloc_bind, (void**)&original_realloc);
        //hookerhelper("free", free_bind, (void**)&original_free);
        hookerhelper("exit", dy_exit, (void**)&original_exit);
        hookerhelper("atexit", dy_atexit, (void**)&original_atexit);
        isSpying = true;
    }
}

void hooker(void)
{
    if(isSpying)
    {
        isSpying = false;
        //hookerhelper("malloc", original_malloc, NULL);
        //hookerhelper("calloc", original_calloc, NULL);
        //hookerhelper("realloc", original_realloc, NULL);
        //hookerhelper("free", original_free, NULL);
        hookerhelper("exit", original_exit, NULL);
        hookerhelper("atexit", original_atexit, NULL);
        malloc_destroy_zone(zone);
    }
}
