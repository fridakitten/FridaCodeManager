#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <stdio.h>

int dyexec(NSString *dylibPath, NSString *arguments) {

    printf("[dyexec] dlopen: %s\n",[dylibPath UTF8String]);
    void *handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "[dyexec] error: %s\n", dlerror());
        return -1;
    }
    printf("[dyexec] handle: 0x%p\n",handle);

    dlerror();

    printf("[dyexec] getting main symbol\n");
    int (*dylib_main)(int, char**) = dlsym(handle, "main");
    char *error = dlerror();
    if (error != NULL) {
        fprintf(stderr, "[dyexec] error: %s\n", error);
        dlclose(handle);
        return -1;
    }
    printf("[dyexec] main symbol found\n");

    NSArray<NSString *> *components = [arguments componentsSeparatedByString:@" "];
    int argc = (int)[components count];
    
    // Allocate memory for argv
    char **argv = (char **)malloc((argc + 1) * sizeof(char *));
    
    // Populate argv with the string components
    for (int i = 0; i < argc; i++) {
        argv[i] = strdup([components[i] UTF8String]);
    }
    argv[argc] = NULL; // argv should be NULL-terminated

    // Call the "main" function of the dylib with argc and argv

    printf("[dyexec] calling symbol\n");
    int result = dylib_main(argc, argv);

    // Free allocated memory
    for (int i = 0; i < argc; i++) {
        free(argv[i]);
    }
    free(argv);

    // Close the dynamic library
    dlclose(handle);

    printf("[dyexec] done\n");
    return result;
}