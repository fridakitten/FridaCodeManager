//
// extra.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>

//custom header
#include "envcontroller.h"

void prntenv() {
    extern char **environ; // Declare the external environment variable array
    char **env = environ;

    while (*env) {
        printf("%s\n", *env); // Print each environment variable
        env++;
    }
}

int cshcd(char **args) {
    if (args[1] == NULL) {
        //fprintf(stderr, "csh: expected argument to \"cd\"\n");
        if (chdir(getenv("HOME")) != 0) {
            perror("csh");
            return 1;
        }
    } else {
        if (chdir(args[1]) != 0) {
            perror("csh");
            return 1;
        }
    }
    setpwd();
    return 0;
}

// Implementation of export command
int cshexp(char **args) {
    if (args[1] == NULL) {
        prntenv();
        return 1;
    } else {
        char *env_var = args[1];
        char *delimiter = strchr(env_var, '=');

        if (delimiter == NULL) {
            fprintf(stderr, "csh: invalid format for export\n");
            return 1;
        }

        *delimiter = '\0';  // Split into name and value
        char *name = env_var;
        char *value = delimiter + 1;

        if (setenv(name, value, 1) != 0) {
            perror("csh");
            return 1;
        }
    }
    return 0;
}

// Function to expand environment variables
void expvar(char **args) {
    for (int i = 0; args[i] != NULL; i++) {
        char *arg = args[i];
        size_t new_arg_size = strlen(arg) + 1;
        char *new_arg = malloc(new_arg_size);
        if (!new_arg) {
            perror("malloc");
            exit(EXIT_FAILURE);
        }
        new_arg[0] = '\0';

        char *start = arg;
        char *dollar = strchr(start, '$');
        while (dollar != NULL) {
            // Copy text before the '$' to new_arg
            strncat(new_arg, start, dollar - start);

            // Find the end of the variable name
            char *end = dollar + 1;
            while (*end && (isalnum(*end) || *end == '_')) {
                end++;
            }

            // Extract the variable name
            char var_name[end - dollar];
            strncpy(var_name, dollar + 1, end - dollar - 1);
            var_name[end - dollar - 1] = '\0';

            // Get the environment variable value
            char *env_var_value = getenv(var_name);
            if (env_var_value) {
                // Calculate the new size needed
                size_t needed_size = strlen(new_arg) + strlen(env_var_value) + strlen(end) + 1;
                if (needed_size > new_arg_size) {
                    new_arg_size = needed_size;
                    new_arg = realloc(new_arg, new_arg_size);
                    if (!new_arg) {
                        perror("realloc");
                        exit(EXIT_FAILURE);
                    }
                }
                // Append the environment variable value to new_arg
                strcat(new_arg, env_var_value);
            }

            // Move start to after the variable name
            start = end;
            dollar = strchr(start, '$');
        }

        // Copy the remaining text after the last '$' to new_arg
        strcat(new_arg, start);

        // Replace the original argument with the expanded one
        args[i] = new_arg;
    }
}