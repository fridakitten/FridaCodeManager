#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <dlfcn.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>
#import <mach-o/reloc.h>
#import <sys/utsname.h>
#import <string.h>
#import <limits.h>
#import <spawn.h>
#import "dyld.h"
#import "sandbox.h"
#import <CoreFoundation/CoreFoundation.h>
#import "shellcode_inject.h"
#import "rop_inject.h"
#import <Foundation/Foundation.h>

char* resolvePath(char* pathToResolve)
{
	if(strlen(pathToResolve) == 0) return NULL;
	if(pathToResolve[0] == '/')
	{
		return strdup(pathToResolve);
	}
	else
	{
		char absolutePath[PATH_MAX];
		if (realpath(pathToResolve, absolutePath) == NULL) {
			perror("[resolvePath] realpath");
			return NULL;
		}
		return strdup(absolutePath);
	}
}

extern int posix_spawnattr_set_ptrauth_task_port_np(posix_spawnattr_t * __restrict attr, mach_port_t port);
void spawnPacChild(int argc, char *argv[])
{
	char** argsToPass = malloc(sizeof(char*) * (argc + 2));
	for(int i = 0; i < argc; i++)
	{
		argsToPass[i] = argv[i];
	}
	argsToPass[argc] = "pac";
	argsToPass[argc+1] = NULL;

	pid_t targetPid = atoi(argv[1]);
	mach_port_t task;
	kern_return_t kr = KERN_SUCCESS;
	kr = task_for_pid(mach_task_self(), targetPid, &task);
	if(kr != KERN_SUCCESS) {
		printf("[spawnPacChild] Failed to obtain task port.\n");
		return;
	}
	printf("[spawnPacChild] Got task port %d for pid %d\n", task, targetPid);

	posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
	posix_spawnattr_set_ptrauth_task_port_np(&attr, task);

	uint32_t executablePathSize = 0;
	_NSGetExecutablePath(NULL, &executablePathSize);
	char *executablePath = malloc(executablePathSize);
	_NSGetExecutablePath(executablePath, &executablePathSize);

	int status = -200;
	pid_t pid;
	int rc = posix_spawn(&pid, executablePath, NULL, &attr, argsToPass, NULL);

	posix_spawnattr_destroy(&attr);
	free(argsToPass);
	free(executablePath);

	if(rc != KERN_SUCCESS)
	{
		printf("[spawnPacChild] posix_spawn failed: %d (%s)\n", rc, mach_error_string(rc));
		return;
	}

	do
	{
		if (waitpid(pid, &status, 0) != -1) {
			printf("[spawnPacChild] Child returned %d\n", WEXITSTATUS(status));
		}
	} while (!WIFEXITED(status) && !WIFSIGNALED(status));

	return;
}

int inject(NSString *inputString) {
	NSArray<NSString *> *components = [inputString componentsSeparatedByString:@" "];
	int argc = (int)[components count];
	char **argv = malloc((argc + 1) * sizeof(char *));
	for (int i = 0; i < argc; i++) {
		NSString *argString = components[i];
		argv[i] = strdup([argString UTF8String]);
	}
	argv[argc] = NULL;

	setlinebuf(stdout);
	setlinebuf(stderr);
	if (argc < 3 || argc > 4)
	{
                printf("Usage: opainject <pid> <path/to/dylib>\n");
		return -1;
	}

#ifdef __arm64e__
	char* pacArg = NULL;
	if(argc >= 4)
	{
		pacArg = argv[3];
	}
	if (!pacArg || (strcmp("pac", pacArg) != 0))
	{
		spawnPacChild(argc, argv);
		return 0;
	}
#endif
	pid_t targetPid = atoi(argv[1]);
	kern_return_t kret = 0;
	task_t procTask = MACH_PORT_NULL;
	char* dylibPath = resolvePath(argv[2]);
	if(!dylibPath) return -3;
	if(access(dylibPath, R_OK) < 0)
	{
		return -4;
	}

	kret = task_for_pid(mach_task_self(), targetPid, &procTask);
        printf("[*] %d\n", targetPid);
	if(kret != KERN_SUCCESS)
	{
                printf("ERROR: task_for_pid failed with error code %d (%s)\n", kret, mach_error_string(kret));
		return -2;
	}
	if(!MACH_PORT_VALID(procTask))
	{
		return -3;
	}

	task_dyld_info_data_t dyldInfo;
	uint32_t count = TASK_DYLD_INFO_COUNT;
	task_info(procTask, TASK_DYLD_INFO, (task_info_t)&dyldInfo, &count);

	injectDylibViaRop(procTask, targetPid, dylibPath, dyldInfo.all_image_info_addr);

	mach_port_deallocate(mach_task_self(), procTask);

        for (int i = 0; i < argc; i++) {
            free(argv[i]);
        }
        free(argv);

	return 0;
}
