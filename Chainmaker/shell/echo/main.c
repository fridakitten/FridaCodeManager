//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void interpret_escapes(const char *str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        if (str[i] == '\\' && str[i + 1] != '\0') {
            switch (str[++i]) {
                case 'a': putchar('\a'); break;
                case 'b': putchar('\b'); break;
                case 'c': return; // Do not print the rest of the line
                case 'e': putchar('\033'); break;
                case 'f': putchar('\f'); break;
                case 'n': putchar('\n'); break;
                case 'r': putchar('\r'); break;
                case 't': putchar('\t'); break;
                case 'v': putchar('\v'); break;
                case '\\': putchar('\\'); break;
                case '\'': putchar('\''); break;
                case '\"': putchar('\"'); break;
                case '?': putchar('\?'); break;
                case '0': // Octal sequence
                    {
                        int octal = 0;
                        int j;
                        for (j = 0; j < 3 && str[i + j] >= '0' && str[i + j] <= '7'; j++) {
                            octal = octal * 8 + (str[i + j] - '0');
                        }
                        putchar(octal);
                        i += j - 1;
                    }
                    break;
                default:
                    putchar('\\');
                    putchar(str[i]);
                    break;
            }
        } else {
            putchar(str[i]);
        }
    }
}

int main(int argc, char *argv[]) {
    int n_flag = 0;
    int e_flag = 0;
    int start_index = 1;

    if (argc > 1) {
        for (int i = 1; i < argc; i++) {
            if (argv[i][0] == '-' && argv[i][1] != '\0') {
                for (int j = 1; argv[i][j] != '\0'; j++) {
                    switch (argv[i][j]) {
                        case 'n':
                            n_flag = 1;
                            break;
                        case 'e':
                            e_flag = 1;
                            break;
                        case 'E':
                            e_flag = 0;
                            break;
                        default:
                            fprintf(stderr, "Unknown option: -%c\n", argv[i][j]);
                            return EXIT_FAILURE;
                    }
                }
                start_index++;
            } else {
                break;
            }
        }
    }

    for (int i = start_index; i < argc; i++) {
        if (e_flag) {
            interpret_escapes(argv[i]);
        } else {
            fputs(argv[i], stdout);
        }

        if (i < argc - 1) {
            putchar(' ');
        }
    }

    if (!n_flag) {
        putchar('\n');
    }

    return EXIT_SUCCESS;
}