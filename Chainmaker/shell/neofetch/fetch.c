//
// fetch.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <unistd.h>
#include <pwd.h>
#include <limits.h>
#include <sys/utsname.h>
#include <string.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <time.h>

#define HOST_NAME_MAX 255

char* gethost() {
    static char hostname[HOST_NAME_MAX];
    if (gethostname(hostname, HOST_NAME_MAX) == 0) {
        return hostname;
    } else {
        return NULL;
    }
}

char* getuser() {
    uid_t uid = geteuid();  // Get effective user ID
    
    struct passwd *pw = getpwuid(uid);
    if (pw == NULL) {
        perror("getpwuid");
        return NULL;
    }
    
    return strdup(pw->pw_name);  // Duplicate and return username
}

char* getkernel() {
    struct utsname buffer;
    if (uname(&buffer) != 0) {
        perror("uname");
        return NULL;
    }

    // Allocate memory for the result string
    size_t result_len = strlen(buffer.sysname) + strlen(buffer.release) + 3; // +3 for space and null terminator
    char *result = (char *)malloc(result_len);
    if (result == NULL) {
        perror("malloc");
        return NULL;
    }

    // Format the kernel info string
    snprintf(result, result_len, "%s %s", buffer.sysname, buffer.release);

    return result;
}

char* getupt() {
    struct timeval boottime;
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    size_t size = sizeof(boottime);

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != 0) {
        perror("sysctl");
        return NULL;
    }

    time_t bsec = boottime.tv_sec;
    time_t csec = time(NULL);

    long uptime = difftime(csec, bsec);
    int days = uptime / (24 * 3600);
    uptime %= (24 * 3600);
    int hours = uptime / 3600;
    uptime %= 3600;
    int minutes = uptime / 60;

    char* result = (char*)malloc(50 * sizeof(char)); // Allocate enough space
    if (result == NULL) {
        perror("malloc");
        return NULL;
    }

    if (days > 0) {
        snprintf(result, 50, "%d day%s, %d hr%s, %d min", days, (days == 1 ? "" : "s"), hours, (hours == 1 ? "" : "s"), minutes);
    } else if (hours > 0) {
        snprintf(result, 50, "%d hr%s, %d min", hours, (hours == 1 ? "" : "s"), minutes);
    } else {
        snprintf(result, 50, "%d min", minutes);
    }

    return result;
}