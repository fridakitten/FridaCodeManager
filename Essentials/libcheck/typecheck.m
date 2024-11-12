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
    } else {
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

NSString* typecheckC(NSArray *stringArray, NSString *content) {
    // preparing unsaved file
    const char *filename = [stringArray.lastObject UTF8String];
    struct CXUnsavedFile cfile;
    cfile.Filename = filename;
    cfile.Contents = (const char*)[content UTF8String];
    cfile.Length = strlen((const char*)[content UTF8String]);

    // typechecking engine
    NSString *result = @"";

    NSInteger count = stringArray.count;
    if (count == 0) {
        fprintf(stderr, "No arguments provided\n");
        return result;
    }

    NSInteger argCount = count - 1;
    char *args[argCount];

    for (NSInteger i = 0; i < argCount; i++) {
        NSString *str = stringArray[i];
        if (str) {
            args[i] = strdup([str UTF8String]);
        } else {
            fprintf(stderr, "Nil argument at index %ld\n", (long)i);
            return result;
        }
    }

    CXIndex index = clang_createIndex(0, 0);
    if (!index) {
        fprintf(stderr, "Failed to create libclang index\n");
        return result;
    }

    CXTranslationUnit tu = clang_parseTranslationUnit(index, filename, (const char* const*)args, argCount, &cfile, 1, CXTranslationUnit_None);

    if (!tu) {
        fprintf(stderr, "Failed to parse %s\n", filename);
    } else {
        result = process_diagnostics(tu, filename);
        clang_disposeTranslationUnit(tu);
    }

    clang_disposeIndex(index);

    for (NSInteger i = 0; i < argCount; i++) {
        free(args[i]);
    }

    return result;
}
