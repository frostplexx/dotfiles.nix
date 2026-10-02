// Spaces across all displays. Spaces are numbered globally: displays left to
// right, and each display's spaces in Mission Control order (fullscreen spaces
// count too).
#pragma once

#include "skylight.h"

#define MAX_DISPLAYS 8
#define MAX_SPACES 128

typedef struct {
    CFStringRef uuid;  // SkyLight display identifier
    CGRect bounds;     // global, top-left origin; CGRectNull if unknown
    uint64_t current;  // space visible on this display
    int first, count;  // range in SpaceMap.ids
} Display;

typedef struct {
    Display displays[MAX_DISPLAYS];
    int ndisplays;
    uint64_t ids[MAX_SPACES];
    int display_of[MAX_SPACES];
    int count;
    int active_display; // display owning the menu bar, or -1
} SpaceMap;

SpaceMap load_spaces(CGSConnectionID cid);

// Global index of the space visible on display d, or -1.
int visible_index(const SpaceMap *map, int d);
