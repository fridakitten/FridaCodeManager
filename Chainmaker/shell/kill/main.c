//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <pid>\n", argv[0]);
        return 1;
    }

    pid_t pid = atoi(argv[1]);

    if (pid == 0) {
        printf("Dont kill the kernel!\n");
        return 0;
    } else if (pid == getppid()) {
        printf("Dont kill your parents!\n");
        return 0;
    } else if (pid == getpid()) {
        printf("Bro can you look into the future!\n");
        return 0;
    } else {
        if (kill(pid, SIGTERM) == -1) {
            perror("kill");
        }
    }

    return 0;
}