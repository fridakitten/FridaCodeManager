//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
//system header
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

//custom header
#include "csh.h"
#include "fetch.h"
#include "cmd_utils.h"
#include "extra.h"
#include "envcontroller.h"

void execute_cmd(char **args) {
    pid_t pid;
    int status;

    pid = fork();
    if (pid < 0) {
        perror("Fork failed");
        exit(1);
    } else if (pid == 0) {
        if (execvp(args[0], args) == -1) {
            perror("Execvp failed");
            exit(1);
        }
    } else {
        waitpid(pid, &status, 0);
    }
}

int main() {
    sethomecwd();
    setpwd();

    char* host = gethost();
    char* user = getuser();
    char* pwd;

    setenv("USER", user, 1);

    char command[MAX_INPUT_LENGTH];
    char *args[MAX_ARGS];

    while (1) {
        pwd = getpwd();

        if (strcmp(pwd, getenv("HOME")) == 0) {
            pwd = "~";
        }

        printf("%s@%s$ ",user,host);

        fflush(stdout);
        read_cmd(command);
        parse_cmd(command, args);

        expvar(args);
        if (args[0] != NULL) {
            if (strcmp(args[0], "cd") == 0) {
                if (cshcd(args) != 0) {
                    fprintf(stderr, "Error: cd command failed\n");
                }
            } else if (strcmp(args[0], "export") == 0) {
                cshexp(args);
            } else if (strcmp(args[0], "info") == 0) {
                printf("NoWay Terminal CSH v0.2\nFirst unsandboxed Terminal on iOS\nMade by.SeanIsNotAConstant\n");
            }  else if (strcmp(args[0], "getpid") == 0) {
                printf("%d\n",getpid());
            }  else if (strcmp(args[0], "getppid") == 0) {
                printf("%d\n",getppid());
            }  else if (strcmp(args[0], "exit") == 0) {
                return 0;
            } else {
                execute_cmd(args);
            }
        }
    }

    return 0;
}