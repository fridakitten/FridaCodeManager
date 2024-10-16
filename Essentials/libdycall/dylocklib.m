#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

void dylocklib(NSString *directoryPath) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];

    if (error) {
        NSLog(@"Error reading directory: %@", error.localizedDescription);
    } else {
        for (NSString *fileName in files) {
            NSString *fullPath = [directoryPath stringByAppendingPathComponent:fileName];
            NSLog(@"Processing file: %@", fullPath);

            BOOL isDirectory;
            [fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];

            if (!isDirectory) {
                dlopen([fullPath UTF8String], RTLD_LAZY);
            }
        }
    }
}
