//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/sysctl.h>
#include <signal.h>
#include <stdbool.h>

void pkill(const char *process_name) {
    int mib[4];
    size_t len;
    int num_processes;
    struct kinfo_proc *procs, *proc;

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    mib[3] = 0;

    if (sysctl(mib, 4, NULL, &len, NULL, 0) == -1) {
        perror("sysctl 1");
        return;
    }

    procs = (struct kinfo_proc *)malloc(len);
    if (procs == NULL) {
        perror("malloc");
        return;
    }

    if (sysctl(mib, 4, procs, &len, NULL, 0) == -1) {
        perror("sysctl 2");
        free(procs);
        return;
    }

    num_processes = len / sizeof(struct kinfo_proc);

    for (int i = 0; i < num_processes; ++i) {
        proc = &procs[i];
        if (strstr(proc->kp_proc.p_comm, process_name) != NULL) {
            pid_t pid = proc->kp_proc.p_pid;
            pid_t parent = getppid();

            if (pid == 0) {
                printf("Dont kill the kernel!\n");
                return;
            } else if (pid == getppid()) {
                printf("Dont kill your parents!\n");
                return;
            } else if (pid == getpid()) {
                printf("Bro can you look into the future!\n");
                return;
            } else {
                if (kill(pid, SIGTERM) == -1) {
                    perror("kill");
                }
            }
        }
    }

    free(procs);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <process_name>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char *process_name = argv[1];
    pkill(process_name);

    return 0;
}