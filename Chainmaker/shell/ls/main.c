//
// main.c
//
// Created by SeanIsNotAConstant on 23.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include <string.h>

void print_file_info(const char *path, const char *name, int human_readable) {
    struct stat file_stat;
    char full_path[1024];
    snprintf(full_path, sizeof(full_path), "%s/%s", path, name);
    
    if (stat(full_path, &file_stat) == -1) {
        perror("stat");
        return;
    }

    printf((S_ISDIR(file_stat.st_mode)) ? "d" : "-");
    printf((file_stat.st_mode & S_IRUSR) ? "r" : "-");
    printf((file_stat.st_mode & S_IWUSR) ? "w" : "-");
    printf((file_stat.st_mode & S_IXUSR) ? "x" : "-");
    printf((file_stat.st_mode & S_IRGRP) ? "r" : "-");
    printf((file_stat.st_mode & S_IWGRP) ? "w" : "-");
    printf((file_stat.st_mode & S_IXGRP) ? "x" : "-");
    printf((file_stat.st_mode & S_IROTH) ? "r" : "-");
    printf((file_stat.st_mode & S_IWOTH) ? "w" : "-");
    printf((file_stat.st_mode & S_IXOTH) ? "x" : "-");

    printf(" %hu", file_stat.st_nlink);

    struct passwd *pw = getpwuid(file_stat.st_uid);
    struct group *gr = getgrgid(file_stat.st_gid);

    printf(" %s %s", pw->pw_name, gr->gr_name);

    if (human_readable) {
        double size = (double)file_stat.st_size;
        const char *units[] = {"B", "K", "M", "G", "T"};
        int unit_index = 0;
        while (size >= 1024 && unit_index < 4) {
            size /= 1024;
            unit_index++;
        }
        printf(" %4.1f%s", size, units[unit_index]);
    } else {
        printf(" %lld", (long long)file_stat.st_size);
    }

    char time_str[256];
    strftime(time_str, sizeof(time_str), "%b %d %H:%M", localtime(&file_stat.st_mtime));
    printf(" %s %s\n", time_str, name);
}

void list_directory(const char *path, int show_all, int long_format, int human_readable) {
    struct dirent *entry;
    DIR *dp = opendir(path);

    if (dp == NULL) {
        perror("opendir");
        return;
    }

    while ((entry = readdir(dp))) {
        if (!show_all && entry->d_name[0] == '.') {
            continue;
        }

        if (long_format) {
            print_file_info(path, entry->d_name, human_readable);
        } else {
            printf("%s\n", entry->d_name);
        }
    }

    closedir(dp);
}

int main(int argc, char *argv[]) {
    const char *path = ".";
    int show_all = 0;
    int long_format = 0;
    int human_readable = 0;

    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            for (int j = 1; argv[i][j] != '\0'; j++) {
                switch (argv[i][j]) {
                    case 'a':
                        show_all = 1;
                        break;
                    case 'l':
                        long_format = 1;
                        break;
                    case 'h':
                        human_readable = 1;
                        break;
                    default:
                        fprintf(stderr, "Unknown option: -%c\n", argv[i][j]);
                        exit(EXIT_FAILURE);
                }
            }
        } else {
            path = argv[i];
        }
    }

    list_directory(path, show_all, long_format, human_readable);

    return 0;
}