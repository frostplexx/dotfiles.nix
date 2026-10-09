#include "util.h"

#include <stdio.h>
#include <stdlib.h>

void die(const char *msg)
{
    fprintf(stderr, "windowbuddy: %s\n", msg);
    exit(1);
}

int64_t dict_i64(CFDictionaryRef dict, const char *key)
{
    if (!dict || CFGetTypeID(dict) != CFDictionaryGetTypeID()) return 0;
    CFStringRef k = CFStringCreateWithCString(NULL, key, kCFStringEncodingUTF8);
    CFNumberRef v = CFDictionaryGetValue(dict, k);
    CFRelease(k);
    int64_t out = 0;
    if (v && CFGetTypeID(v) == CFNumberGetTypeID()) CFNumberGetValue(v, kCFNumberSInt64Type, &out);
    return out;
}
