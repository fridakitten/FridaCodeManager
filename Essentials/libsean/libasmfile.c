//
// libasmfile.c
// Sean16Compiler
//

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define MAX_INSTRUCTIONS 1000
#define MAX_ARGS 6

uint8_t** readasm(const char *filename) {
    // Dynamically allocate memory for a 2D array (1000 x 6)
    uint8_t **array = (uint8_t **)malloc(MAX_INSTRUCTIONS * sizeof(uint8_t *));
    if (array == NULL) {
        perror("Error allocating memory for rows");
        return NULL;
    }
    
    for (int i = 0; i < MAX_INSTRUCTIONS; i++) {
        array[i] = (uint8_t *)malloc(MAX_ARGS * sizeof(uint8_t));
        if (array[i] == NULL) {
            perror("Error allocating memory for columns");
            // Free any already allocated memory in case of failure
            for (int j = 0; j < i; j++) {
                free(array[j]);
            }
            free(array);
            return NULL;
        }
    }

    // Open the file in binary read mode
    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        perror("Error opening file");
        // Free the allocated memory before returning
        for (int i = 0; i < MAX_INSTRUCTIONS; i++) {
            free(array[i]);
        }
        free(array);
        return NULL;
    }

    // Read the values into the 2D array
    for (int i = 0; i < MAX_INSTRUCTIONS; i++) {
        if (fread(array[i], sizeof(uint8_t), MAX_ARGS, file) != MAX_ARGS) {
            if (feof(file)) {
                printf("Warning: End of file reached before reading all data.\n");
            } else if (ferror(file)) {
                perror("Error reading file");
            }
            break;
        }
    }

    // Close the file
    fclose(file);

    // Return the pointer to the 2D array
    return array;
}

void storeasm(const char *filename, uint8_t *values, size_t size) {
    // Open the file in binary write mode
    FILE *file = fopen(filename, "wb");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }

    // Write the array of 8-bit values to the file
    size_t written = fwrite(values, sizeof(uint8_t), size, file);
    if (written != size) {
        perror("Error writing to file");
    }

    // Close the file
    fclose(file);
}
