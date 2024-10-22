#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINES 1000
#define MAX_WORDS 6
#define MAX_WORD_LENGTH 50
#define MAX_LINE_LENGTH 256

char *(*read_file(char *filename))[MAX_WORDS] {
    static char *content[MAX_LINES][MAX_WORDS];  // Statically allocated array
    FILE *file = fopen(filename, "r");
    
    if (file == NULL) {
        printf("Error: Could not open file.\n");
        return NULL;
    }

    char line[MAX_LINE_LENGTH];
    int line_number = 0;

    // Read file line by line
    while (fgets(line, sizeof(line), file) != NULL && line_number < MAX_LINES) {
        char *word;
        int word_number = 0;

        // Tokenize each line into words using spaces as a delimiter
        word = strtok(line, " \t\n");
        while (word != NULL && word_number < MAX_WORDS) {
            // Allocate memory for the word and store it in the content array
            content[line_number][word_number] = malloc(strlen(word) + 1);
            strcpy(content[line_number][word_number], word);
            
            word_number++;
            word = strtok(NULL, " \t\n");
        }

        // Fill remaining words with NULL if less than MAX_WORDS
        for (int i = word_number; i < MAX_WORDS; i++) {
            content[line_number][i] = NULL;
        }

        line_number++;
    }

    fclose(file);
    return content;
}

void free_content(char *content[MAX_LINES][MAX_WORDS]) {
    // Free all dynamically allocated memory
    for (int i = 0; i < MAX_LINES; i++) {
        for (int j = 0; j < MAX_WORDS; j++) {
            if (content[i][j] != NULL) {
                free(content[i][j]);
            }
        }
    }
}
