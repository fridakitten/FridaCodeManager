#include <stdio.h>
#include <Foundation/Foundation.h>

extern int inject(NSString *inputString);

int main(void) {
    int result = inject(@"opainject 30319 debug.dylib");
    printf("%d\n", result);
}
