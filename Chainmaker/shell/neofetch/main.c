//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "fetch.h"

int main() {
    char *secon = "             \033[0m--------------\033[32m";
    char *seven = "       Shell\033[0m: csh\033[93m";
    char *ninth = "";
    char *tenth = "          \033[93mGPU\033[0m: Unknown\033[91m";
    printf("                    \033[32mc.'             \033[0m%s@%s\033[32m\n                 ,xNMM.%s\n               .OMMMMo              \033[93mOS\033[0m: iOS %s\033[32m\n               lMMM\"                \033[93mHost\033[0m: %s\033[32m\n     .;loddo:.  .olloddol;.         \033[93mKernel\033[0m: %s\033[32m\n   cKMMMMMMMMMMNWMMMMMMMMMM0:       \033[93mUptime\033[0m: %s\033[93m\n \033[93m.KMMMMMMMMMMMMMMMMMMMMMMMWd.%s\n XMMMMMMMMMMMMMMMMMMMMMMMX.         Resolution\033[0m: %s\033[93m\n\033[91m;MMMMMMMMMMMMMMMMMMMMMMMM.          \033[93mCPU\033[0m: %s\033[91m\n:MMMMMMMMMMMMMMMMMMMMMMMM:\n.MMMMMMMMMMMMMMMMMMMMMMMMX.\n kMMMMMMMMMMMMMMMMMMMMMMMMWd.\n \033[95m'XMMMMMMMMMMMMMMMMMMMMMMMMMMk.\n  'XMMMMMMMMMMMMMMMMMMMMMMMMK.\n    \033[94mkMMMMMMMMMMMMMMMMMMMMMMd\n     ;KMMMMMMMWXXWMMMMMMMk.\n        cooc*      *coo \n \n\033[0m",getuser(),gethost(),secon,getosver(),getmodel(),getkernel(),getupt(),seven,getres(),getcpu());
}