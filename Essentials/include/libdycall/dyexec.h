#include <Foundation/Foundation.h>

//posix_spawn for dybinaries
int dyexec(NSString *dylibPath, NSString *arguments);

//locking/unlocking dybinary
void dylock(NSString *dylibPath);
void dyunlock();

//freeing dylib utils
void listdylibs();