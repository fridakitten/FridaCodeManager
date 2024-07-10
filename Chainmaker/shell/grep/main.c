//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <dirent.h>
#include <sys/stat.h>

#define MAX_LINE_LENGTH 1024

void print_usage(const char *program_name) {
    fprintf(stderr, "Usage: %s [-i] [-r] [-w] [-n] [-c] [-v] [-l] [-e pattern] [-f file] pattern [file/directory]\n", program_name);
}

void grep(FILE *file, const char *pattern, bool ignore_case, bool match_whole_word, bool print_line_numbers, bool invert_match, bool print_file_names) {
    char line[MAX_LINE_LENGTH];
    int line_number = 0;
    bool match_found = false;

    while (fgets(line, sizeof(line), file)) {
        line_number++;

        // Remove trailing newline character if present
        line[strcspn(line, "\n")] = '\0';

        // Case insensitive comparison if ignore_case is true
        const char *line_to_search = ignore_case ? strcasestr(line, pattern) : strstr(line, pattern);

        // Check for whole word match if required
        if (line_to_search && match_whole_word) {
            const char *start = line_to_search;
            const char *end = line_to_search + strlen(pattern);

            // Check if the match is a whole word
            if ((start == line || !isalnum(*(start - 1))) && (!isalnum(*end) || *end == '\0')) {
                line_to_search = line_to_search;
            } else {
                line_to_search = NULL;
            }
        }

        if ((line_to_search && !invert_match) || (!line_to_search && invert_match)) {
            match_found = true;

            // Print output according to flags
            if (print_file_names) {
                printf("%s: ", "filename"); // Replace "filename" with actual filename or use an additional parameter
            }
            if (print_line_numbers) {
                printf("%d: ", line_number);
            }
            printf("%s\n", line);
        }
    }

    if (print_file_names && match_found && !print_line_numbers) {
        printf("%s\n", "filename"); // Replace "filename" with actual filename or use an additional parameter
    }
}

void grep_recursive(const char *pattern, bool ignore_case, bool match_whole_word, bool print_line_numbers, bool invert_match, bool print_file_names, const char *dirname) {
    DIR *dir = opendir(dirname);
    if (dir == NULL) {
        perror("Error opening directory");
        return;
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) {
            // Regular file, apply grep
            char path[MAX_LINE_LENGTH];
            snprintf(path, sizeof(path), "%s/%s", dirname, entry->d_name);

            FILE *file = fopen(path, "r");
            if (file != NULL) {
                printf("\n%s:\n", path);
                grep(file, pattern, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names);
                fclose(file);
            } else {
                perror("Error opening file");
            }
        } else if (entry->d_type == DT_DIR && strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
            // Directory, recurse into it if -r flag is set
            char path[MAX_LINE_LENGTH];
            snprintf(path, sizeof(path), "%s/%s", dirname, entry->d_name);
            grep_recursive(pattern, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names, path);
        }
    }

    closedir(dir);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        print_usage(argv[0]);
        return 1;
    }

    bool ignore_case = false;
    bool recursive = false;
    bool match_whole_word = false;
    bool print_line_numbers = false;
    bool count_only = false;
    bool invert_match = false;
    bool print_file_names = false;
    const char *pattern = NULL;
    const char *file_or_dir = NULL;
    const char *patterns_file = NULL;

    // Parse options and arguments
    int i = 1;
    while (i < argc) {
        if (strcmp(argv[i], "-i") == 0) {
            ignore_case = true;
        } else if (strcmp(argv[i], "-r") == 0) {
            recursive = true;
        } else if (strcmp(argv[i], "-w") == 0) {
            match_whole_word = true;
        } else if (strcmp(argv[i], "-n") == 0) {
            print_line_numbers = true;
        } else if (strcmp(argv[i], "-c") == 0) {
            count_only = true;
        } else if (strcmp(argv[i], "-v") == 0) {
            invert_match = true;
        } else if (strcmp(argv[i], "-l") == 0) {
            print_file_names = true;
        } else if (strcmp(argv[i], "-e") == 0 && i + 1 < argc) {
            pattern = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "-f") == 0 && i + 1 < argc) {
            patterns_file = argv[i + 1];
            i++;
        } else if (pattern == NULL) {
            pattern = argv[i];
        } else if (file_or_dir == NULL) {
            file_or_dir = argv[i];
        } else {
            fprintf(stderr, "Unknown option or parameter: %s\n", argv[i]);
            print_usage(argv[0]);
            return 1;
        }
        i++;
    }

    // Check for mandatory arguments
    if (pattern == NULL) {
        fprintf(stderr, "Pattern not specified.\n");
        print_usage(argv[0]);
        return 1;
    }

    if (file_or_dir == NULL) {
        fprintf(stderr, "File or directory not specified.\n");
        print_usage(argv[0]);
        return 1;
    }

    // Handle patterns from file if specified
    if (patterns_file != NULL) {
        FILE *file = fopen(patterns_file, "r");
        if (file == NULL) {
            perror("Error opening patterns file");
            return 1;
        }

        char line[MAX_LINE_LENGTH];
        while (fgets(line, sizeof(line), file)) {
            // Remove trailing newline character if present
            line[strcspn(line, "\n")] = '\0';

            if (recursive) {
                grep_recursive(line, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names, file_or_dir);
            } else {
                FILE *f = fopen(file_or_dir, "r");
                if (f != NULL) {
                    printf("\n%s:\n", file_or_dir);
                    grep(f, line, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names);
                    fclose(f);
                } else {
                    perror("Error opening file");
                }
            }
        }

        fclose(file);
        return 0;
    }

    // Determine if file_or_dir is a directory or file
    struct stat path_stat;
    if (stat(file_or_dir, &path_stat) != 0) {
        perror("Error getting file/directory status");
        return 1;
    }

    if (S_ISDIR(path_stat.st_mode)) {
        // Directory, grep recursively if -r flag is set
        if (recursive) {
            grep_recursive(pattern, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names, file_or_dir);
        } else {
            // Not supported, handle as regular file
            FILE *file = fopen(file_or_dir, "r");
            if (file != NULL) {
                printf("\n%s:\n", file_or_dir);
                grep(file, pattern, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names);
                fclose(file);
            } else {
                perror("Error opening file");
            }
        }
    } else if (S_ISREG(path_stat.st_mode)) {
        // Regular file
        FILE *file = fopen(file_or_dir, "r");
        if (file != NULL) {
            grep(file, pattern, ignore_case, match_whole_word, print_line_numbers, invert_match, print_file_names);
            fclose(file);
        } else {
            perror("Error opening file");
        }
    } else {
        fprintf(stderr, "%s is not a regular file or directory.\n", file_or_dir);
        return 1;
    }

    return 0;
}