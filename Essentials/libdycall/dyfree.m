// under construction!!!

#include <mach-o/dyld.h>
#include <stdio.h>

void listdylibs()
{
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char* name = _dyld_get_image_name(i);
        const struct mach_header* header = _dyld_get_image_header(i);
        printf("Library: %s, Address: %p\n", name, header);
    }
}
