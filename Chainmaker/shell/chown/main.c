//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <pwd.h>
#include <grp.h>
#include <string.h>
#include <errno.h>

void change_owner(const char *path, uid_t uid, gid_t gid) {
    if (chown(path, uid, gid) == -1) {
        fprintf(stderr, "Error: Failed to change ownership of %s: %s\n", path, strerror(errno));
    } else {
        printf("Changed ownership of %s\n", path);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s owner:group file/dir [file/dir...]\n", argv[0]);
        return 1;
    }

    char *owner_group = argv[1];
    char *colon = strchr(owner_group, ':');
    if (!colon) {
        fprintf(stderr, "Error: Missing colon separating owner and group\n");
        return 1;
    }
    
    *colon = '\0';
    char *owner = owner_group;
    char *group = colon + 1;

    struct passwd *pwd = getpwnam(owner);
    if (!pwd) {
        fprintf(stderr, "Error: User %s not found\n", owner);
        return 1;
    }
    uid_t uid = pwd->pw_uid;

    struct group *grp = getgrnam(group);
    if (!grp) {
        fprintf(stderr, "Error: Group %s not found\n", group);
        return 1;
    }
    gid_t gid = grp->gr_gid;

    for (int i = 2; i < argc; ++i) {
        change_owner(argv[i], uid, gid);
    }

    return 0;
}