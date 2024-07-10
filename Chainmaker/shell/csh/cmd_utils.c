//
// cmd_utils.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//custom headers
#include "csh.h"

// Function to read command from user input
void read_cmd(char *command) {
    fgets(command, MAX_INPUT_LENGTH, stdin);
    // Remove newline character at the end
    command[strcspn(command, "\n")] = '\0';
}

// Function to parse command into arguments
void parse_cmd(char *command, char **args) {
    char *token;
    int i = 0;

    token = strtok(command, " ");
    while (token != NULL && i < MAX_ARGS - 1) {
        args[i++] = token;
        token = strtok(NULL, " ");
    }
    args[i] = NULL;  // Null-terminate the argument list
}