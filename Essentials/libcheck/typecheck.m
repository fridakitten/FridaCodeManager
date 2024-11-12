#import <Foundation/Foundation.h>
#include <clang-c/Index.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>

NSString* process_diagnostics(CXTranslationUnit tu, const char *filename) {
    unsigned int diagnosticCount = clang_getNumDiagnostics(tu);
    if (diagnosticCount == 0) {
        printf("No diagnostics for %s\n", filename);
    } else {
        //NSString("%s:\n", filename);
        for (unsigned int i = 0; i < diagnosticCount; i++) {
            CXDiagnostic diagnostic = clang_getDiagnostic(tu, i);
            CXString diagnosticStr = clang_formatDiagnostic(diagnostic, clang_defaultDiagnosticDisplayOptions());
            NSString *result = [NSString stringWithFormat:@"%s\n", clang_getCString(diagnosticStr)];
            clang_disposeString(diagnosticStr);
            clang_disposeDiagnostic(diagnostic);
            return result;
        }
    }

    return @"";
}

NSString* typecheckC(NSArray *stringArray) {
    NSString *result = @"";

    NSInteger count = stringArray.count;
    if (count == 0) {
        fprintf(stderr, "No arguments provided\n");
        return result;
    }

    // Separate filename and arguments
    const char *filename = [stringArray.lastObject UTF8String];
    NSInteger argCount = count - 1;
    char *args[argCount];

    // Populate args array with compiler arguments (excluding filename)
    for (NSInteger i = 0; i < argCount; i++) {
        NSString *str = stringArray[i];
        if (str) {
            args[i] = strdup([str UTF8String]);  // Convert NSString to char* and store in args
        } else {
            fprintf(stderr, "Nil argument at index %ld\n", (long)i);
            return result;
        }
    }

    CXIndex index = clang_createIndex(0, 0);  // Create a libclang index
    if (!index) {
        fprintf(stderr, "Failed to create libclang index\n");
        return result;
    }

    // Parse the translation unit with filename and arguments
    CXTranslationUnit tu = clang_parseTranslationUnit(index, filename, (const char* const*)args, argCount, NULL, 0, CXTranslationUnit_None);

    if (!tu) {
        fprintf(stderr, "Failed to parse %s\n", filename);
    } else {
        result = process_diagnostics(tu, filename);  // Process any diagnostics
        clang_disposeTranslationUnit(tu);  // Dispose the translation unit when done
    }

    clang_disposeIndex(index);  // Dispose of the index when done

    // Free the dynamically allocated char* array
    for (NSInteger i = 0; i < argCount; i++) {
        free(args[i]);
    }

    return result;
}