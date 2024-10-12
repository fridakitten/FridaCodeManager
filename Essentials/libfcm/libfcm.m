#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/sysctl.h>
#include <signal.h>
#include <stdbool.h>
#import "libfcm.h"

@interface MCMContainer : NSObject
- (NSURL *)url;
+ (instancetype)containerWithIdentifier:(NSString *)identifier
                      createIfNecessary:(BOOL)createIfNecessary
                                existed:(BOOL *)existed
                                  error:(NSError **)error;
@end

@interface MCMAppDataContainer : MCMContainer
@end

NSString *ghost() {
    return [[NSProcessInfo processInfo] hostName];
}


NSString *gosver() {
    return [[UIDevice currentDevice] systemVersion];
}

NSString *gos() {
    return [[UIDevice currentDevice] systemName];
}

NSString *gosb() {
    size_t size;
    sysctlbyname("kern.osversion", NULL, &size, NULL, 0);
    char *version = malloc(size);
    sysctlbyname("kern.osversion", version, &size, NULL, 0);
    NSString *buildNumber = [NSString stringWithUTF8String:version];
    free(version); // Don't forget to free the allocated memory
    return buildNumber;
}

NSString *gmodel() {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return modelName;
}

NSString *gcpu() {
    NSString *machine = gmodel();
    NSString *iphoneFamily = [machine substringToIndex:[machine length] - 2];
    
    NSDictionary *cpuNames = @{
        @"iPhone1": @"APL0098",
        @"iPhone2": @"APL0098",
        @"iPhone3": @"Apple A4",
        @"iPhone4": @"Apple A5",
        @"iPhone5": @"Apple A6",
        @"iPhone6": @"Apple A7",
        @"iPhone7": @"Apple A8",
        @"iPhone8": @"Apple A9",
        @"iPhone9": @"Apple A10 Fusion",
        @"iPhone10": @"Apple A11 Bionic",
        @"iPhone11": @"Apple A12 Bionic",
        @"iPhone12": @"Apple A13 Bionic",
        @"iPhone13": @"Apple A14 Bionic",
        @"iPhone14": @"Apple A15 Bionic",
        @"iPhone15": @"Apple A16 Bionic",
        @"iPhone16": @"Apple A16 Bionic",
    };

    NSString *cpuName = cpuNames[iphoneFamily] ?: @"Unknown";
    return cpuName;
}

NSString *garch() {
    NSString *machine = gmodel();
    NSString *iphoneFamily = [machine substringToIndex:[machine length] - 2];
    
    NSDictionary *cpuNames = @{
        @"iPhone1": @"armv6",
        @"iPhone2": @"armv6",
        @"iPhone3": @"armv7",
        @"iPhone4": @"armv7",
        @"iPhone5": @"armv7",
        @"iPhone6": @"armv8",
        @"iPhone7": @"armv8",
        @"iPhone8": @"armv8",
        @"iPhone9": @"arm64",
        @"iPhone10": @"arm64",
        @"iPhone11": @"arm64e",
        @"iPhone12": @"arm64e",
        @"iPhone13": @"arm64e",
        @"iPhone14": @"arm64e",
        @"iPhone15": @"arm64e",
        @"iPhone16": @"arm64e",
    };

    NSString *cpuName = cpuNames[iphoneFamily] ?: @"Unknown";
    return cpuName;
}

NSString *container_saved = nil;
NSString* contgen(void) {
    if(container_saved == nil) {
        MCMAppDataContainer* container = [MCMAppDataContainer containerWithIdentifier:NSBundle.mainBundle.bundleIdentifier createIfNecessary:YES existed:nil error:nil];
        container_saved = container.url.path;
    }
    
    return container_saved;
}

//process
void pkill(NSString *processNS) {
    int mib[4];
    size_t len;
    int num_processes;
    struct kinfo_proc *procs, *proc;

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    mib[3] = 0;

    if (sysctl(mib, 4, NULL, &len, NULL, 0) == -1) {
        perror("sysctl 1");
        return;
    }

    procs = (struct kinfo_proc *)malloc(len);
    if (procs == NULL) {
        perror("malloc");
        return;
    }

    if (sysctl(mib, 4, procs, &len, NULL, 0) == -1) {
        perror("sysctl 2");
        free(procs);
        return;
    }

    num_processes = len / sizeof(struct kinfo_proc);

    for (int i = 0; i < num_processes; ++i) {
        proc = &procs[i];
        if (strstr(proc->kp_proc.p_comm, [processNS UTF8String]) != NULL) {
            pid_t pid = proc->kp_proc.p_pid;
            pid_t parent = getppid();

            if (pid == 0) {
                printf("Dont kill the kernel!\n");
                return;
            } else if (pid == getppid()) {
                printf("Dont kill your parents!\n");
                return;
            } else if (pid == getpid()) {
                printf("Bro can you look into the future!\n");
                return;
            } else {
                if (kill(pid, SIGTERM) == -1) {
                    perror("kill");
                }
            }
        }
    }

    free(procs);
}
