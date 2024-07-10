//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

int main() {
    uid_t uid = getuid();  // Get the real user ID
    uid_t euid = geteuid();  // Get the effective user ID
    gid_t gid = getgid();  // Get the real group ID
    gid_t egid = getegid();  // Get the effective group ID

    printf("uid=%d(%s) gid=%d(%s) euid=%d(%s) egid=%d(%s)\n",
           uid, getlogin(), gid, getlogin(), euid, getlogin(), egid, getlogin());

    // Print supplementary group IDs
    int num_groups = 0;
    gid_t *groups = NULL;
    num_groups = getgroups(0, NULL);  // Get number of groups
    if (num_groups > 0) {
        groups = malloc(num_groups * sizeof(gid_t));
        getgroups(num_groups, groups);  // Get the group list
        printf("groups=");
        for (int i = 0; i < num_groups; ++i) {
            printf("%d", groups[i]);
            if (i < num_groups - 1) {
                printf(",");
            }
        }
        printf("\n");
        free(groups);
    }

    return EXIT_SUCCESS;
}