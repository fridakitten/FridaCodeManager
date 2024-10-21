#import <Foundation/Foundation.h>
#import <stdio.h>
#import <unistd.h>

void removeFileAt(NSString *filePath) {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;

        [fileManager removeItemAtPath:filePath error:&error];
    }
}

void redirectOutput(NSString *docsPath) {
    printf("[*] hello from FCM!\n");
    NSString *stdoutFilePath = [docsPath stringByAppendingPathComponent:@"stdout.txt"];
    NSString *stderrFilePath = [docsPath stringByAppendingPathComponent:@"stderr.txt"];

    removeFileAt(stdoutFilePath);
    removeFileAt(stderrFilePath);

    FILE *stdoutFile = fopen([stdoutFilePath UTF8String], "w");
    FILE *stderrFile = fopen([stderrFilePath UTF8String], "w");

    if (stdoutFile == NULL || stderrFile == NULL) {
        perror("Failed to open output files");
        exit(EXIT_FAILURE);
    }

    dup2(fileno(stdoutFile), STDOUT_FILENO);
    dup2(fileno(stderrFile), STDERR_FILENO);

    fclose(stdoutFile);
    fclose(stderrFile);
}

__attribute__((constructor))
void init() {
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    printf("[*] %s\n", [docsPath UTF8String]);
    redirectOutput(docsPath);
}

