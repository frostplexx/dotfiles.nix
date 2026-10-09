// Private SkyLight SPI, resolved at runtime. These symbols aren't in any SDK
// header and can change between macOS releases.
#pragma once

#include "util.h"

typedef int CGSConnectionID;

extern CGSConnectionID (*SLSMainConnectionID)(void);
extern CFArrayRef (*SLSCopyManagedDisplaySpaces)(CGSConnectionID cid);
extern CFStringRef (*SLSCopyActiveMenuBarDisplayIdentifier)(CGSConnectionID cid);
extern uint64_t (*SLSManagedDisplayGetCurrentSpace)(CGSConnectionID cid, CFStringRef display);
// Optional: NULL when the running macOS doesn't export them.
extern void (*SLSMoveWindowsToManagedSpace)(CGSConnectionID cid, CFArrayRef windows, uint64_t sid);
extern CFArrayRef (*SLSCopySpacesForWindows)(CGSConnectionID cid, int mask, CFArrayRef windows);
extern void (*SLSSetActiveMenuBarDisplayIdentifier)(CGSConnectionID cid, CFStringRef display, CFStringRef display2);

// Load SkyLight and resolve the symbols above; dies if a required one is missing.
void load_skylight(void);

// A one-element CFArray holding `wid` in the form SkyLight expects. Caller releases.
CFArrayRef window_array(CGWindowID wid) CF_RETURNS_RETAINED;

// The space the window in `windows` (from window_array) is on, or 0.
uint64_t window_space(CGSConnectionID cid, CFArrayRef windows);

// Queue a move of `windows` to space `sid` via the bridged operation macOS 26+
// requires. Asynchronous: the main run loop must run for it to be delivered.
// Returns false if this macOS lacks the operation.
bool move_windows_bridged(CFArrayRef windows, uint64_t sid);
