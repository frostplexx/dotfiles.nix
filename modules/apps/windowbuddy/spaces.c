#include "spaces.h"

#include <stdlib.h>

// Bounds of the display SkyLight calls `uuid` (the main display may be "Main").
static CGRect display_bounds(CFStringRef uuid)
{
    if (CFEqual(uuid, CFSTR("Main"))) return CGDisplayBounds(CGMainDisplayID());

    CGDirectDisplayID ids[MAX_DISPLAYS];
    uint32_t n = 0;
    CGGetActiveDisplayList(MAX_DISPLAYS, ids, &n);
    for (uint32_t i = 0; i < n; i++) {
        CFUUIDRef u = CGDisplayCreateUUIDFromDisplayID(ids[i]);
        if (!u) continue;
        CFStringRef str = CFUUIDCreateString(NULL, u);
        CFRelease(u);
        bool match = CFStringCompare(str, uuid, kCFCompareCaseInsensitive) == kCFCompareEqualTo;
        CFRelease(str);
        if (match) return CGDisplayBounds(ids[i]);
    }
    return CGRectNull;
}

static int compare_display_x(const void *a, const void *b)
{
    double ax = ((const Display *)a)->bounds.origin.x, bx = ((const Display *)b)->bounds.origin.x;
    return (ax > bx) - (ax < bx);
}

SpaceMap load_spaces(CGSConnectionID cid)
{
    SpaceMap map = { .ndisplays = 0, .count = 0, .active_display = -1 };

    CFArrayRef displays = SLSCopyManagedDisplaySpaces(cid);
    if (!displays) die("could not list spaces");

    // Collect each display's space ids, then order displays left to right.
    uint64_t raw[MAX_DISPLAYS][MAX_SPACES];
    for (CFIndex d = 0; d < CFArrayGetCount(displays) && map.ndisplays < MAX_DISPLAYS; d++) {
        CFDictionaryRef ddict = CFArrayGetValueAtIndex(displays, d);
        if (CFGetTypeID(ddict) != CFDictionaryGetTypeID()) continue;
        CFStringRef uuid = CFDictionaryGetValue(ddict, CFSTR("Display Identifier"));
        CFArrayRef spaces = CFDictionaryGetValue(ddict, CFSTR("Spaces"));
        if (!uuid || CFGetTypeID(uuid) != CFStringGetTypeID()) continue;
        if (!spaces || CFGetTypeID(spaces) != CFArrayGetTypeID()) continue;

        Display *disp = &map.displays[map.ndisplays];
        disp->uuid = CFRetain(uuid);
        disp->bounds = display_bounds(uuid);
        disp->current = SLSManagedDisplayGetCurrentSpace(cid, uuid);
        disp->count = 0;
        for (CFIndex s = 0; s < CFArrayGetCount(spaces) && disp->count < MAX_SPACES; s++)
            raw[map.ndisplays][disp->count++] = (uint64_t)dict_i64(CFArrayGetValueAtIndex(spaces, s), "id64");
        disp->first = map.ndisplays; // remember raw row until sorted
        map.ndisplays++;
    }
    CFRelease(displays);
    if (map.ndisplays == 0) die("could not list spaces");

    qsort(map.displays, (size_t)map.ndisplays, sizeof(Display), compare_display_x);

    for (int d = 0; d < map.ndisplays; d++) {
        Display *disp = &map.displays[d];
        int row = disp->first;
        disp->first = map.count;
        int kept = 0;
        for (int s = 0; s < disp->count && map.count < MAX_SPACES; s++, kept++) {
            map.ids[map.count] = raw[row][s];
            map.display_of[map.count++] = d;
        }
        // Spaces past MAX_SPACES are dropped; keep [first, first + count)
        // inside ids so visible_index can't read past the array.
        disp->count = kept;
    }

    CFStringRef active = SLSCopyActiveMenuBarDisplayIdentifier(cid);
    if (active) {
        uint64_t active_sid = SLSManagedDisplayGetCurrentSpace(cid, active);
        CFRelease(active);
        for (int d = 0; d < map.ndisplays; d++)
            if (map.displays[d].current == active_sid) map.active_display = d;
    }
    return map;
}

int visible_index(const SpaceMap *map, int d)
{
    const Display *disp = &map->displays[d];
    for (int i = disp->first; i < disp->first + disp->count; i++)
        if (map->ids[i] == disp->current) return i;
    return -1;
}
