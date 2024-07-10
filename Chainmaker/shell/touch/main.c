//
// main.c
//
// Created by SeanIsNotAConstant on 25.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <utime.h>
#include <sys/stat.h>
#include <unistd.h>

void print_usage() {
    printf("Usage: touch [OPTION]... FILE...\n");
    printf("Update the access and modification times of each FILE to the current time.\n\n");
    printf("A FILE argument that does not exist is created empty, unless -c or -h is supplied.\n\n");
    printf("Options:\n");
    printf("  -a                     change only the access time\n");
    printf("  -m                     change only the modification time\n");
    printf("  -c, --no-create        do not create any files\n");
    printf("  -d, --date=STRING      parse STRING and use it instead of current time\n");
    printf("  -r, --reference=FILE   use this file's times instead of current time\n");
    printf("  -t STAMP               use [[CC]YY]MMDDhhmm[.ss] instead of current time\n");
    printf("  --help                 display this help and exit\n");
}

void parse_date(const char *date_str, struct tm *tm) {
    memset(tm, 0, sizeof(struct tm));
    strptime(date_str, "%Y-%m-%d %H:%M:%S", tm);
}

void parse_timestamp(const char *timestamp_str, struct tm *tm) {
    memset(tm, 0, sizeof(struct tm));
    strptime(timestamp_str, "%Y%m%d%H%M.%S", tm);
}

int main(int argc, char *argv[]) {
    int opt;
    int change_atime = 1, change_mtime = 1, no_create = 0;
    char *date_str = NULL, *timestamp_str = NULL, *ref_file = NULL;
    struct tm tm;
    struct stat ref_stat;
    struct utimbuf new_times;

    while ((opt = getopt(argc, argv, "amcd:t:r:")) != -1) {
        switch (opt) {
            case 'a':
                change_mtime = 0;
                break;
            case 'm':
                change_atime = 0;
                break;
            case 'c':
                no_create = 1;
                break;
            case 'd':
                date_str = optarg;
                break;
            case 't':
                timestamp_str = optarg;
                break;
            case 'r':
                ref_file = optarg;
                break;
            default:
                print_usage();
                return EXIT_FAILURE;
        }
    }

    if (optind >= argc) {
        print_usage();
        return EXIT_FAILURE;
    }

    if (ref_file && stat(ref_file, &ref_stat) == -1) {
        perror("stat");
        return EXIT_FAILURE;
    }

    time_t current_time = time(NULL);

    if (date_str) {
        parse_date(date_str, &tm);
        current_time = mktime(&tm);
    } else if (timestamp_str) {
        parse_timestamp(timestamp_str, &tm);
        current_time = mktime(&tm);
    } else if (ref_file) {
        new_times.actime = ref_stat.st_atime;
        new_times.modtime = ref_stat.st_mtime;
    } else {
        new_times.actime = current_time;
        new_times.modtime = current_time;
    }

    for (int i = optind; i < argc; i++) {
        const char *filename = argv[i];

        if (stat(filename, &ref_stat) == -1) {
            if (!no_create) {
                FILE *file = fopen(filename, "w");
                if (!file) {
                    perror("fopen");
                    return EXIT_FAILURE;
                }
                fclose(file);
            } else {
                continue;
            }
        }

        if (!ref_file) {
            if (change_atime) new_times.actime = current_time;
            if (change_mtime) new_times.modtime = current_time;
        }

        if (utime(filename, &new_times) == -1) {
            perror("utime");
            return EXIT_FAILURE;
        }
    }

    return EXIT_SUCCESS;
}