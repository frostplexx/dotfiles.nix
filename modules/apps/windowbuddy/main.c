// windowbuddy — tiny stateless window/space helper for macOS.
//
//   windowbuddy focus <left|right|up|down>   focus the nearest window in a direction
//   windowbuddy space <n>                    switch to space n (on whichever display has it)
//   windowbuddy move <n>                     move the focused window to space n and follow it
//
// Spaces are numbered from 1 across all displays (see spaces.h). Ported from
// agate-wm (frostplexx/agate-wm) and WindowKit (ejbills/WindowKit); the private
// SkyLight bits mirror yabai.
//
// Needs Accessibility permission (focus + synthetic gestures).

#include "gesture.h"
#include "skylight.h"
#include "spaces.h"
#include "windows.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// From AppKit; declared here to avoid pulling Objective-C headers into C.
extern bool NSApplicationLoad(void);

typedef enum { DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN } Direction;

static int cmd_focus(Direction dir)
{
    Window windows[MAX_WINDOWS];
    int n = visible_windows(windows, MAX_WINDOWS);
    if (n == 0) return 1;

    // Source is the focused window, or the frontmost one if nothing has focus.
    CGWindowID focused = focused_window();
    int src = 0;
    for (int i = 0; i < n; i++)
        if (windows[i].wid == focused) src = i;

    CGRect s = windows[src].frame;
    double sx = CGRectGetMidX(s), sy = CGRectGetMidY(s);

    int best = -1;
    double best_score = INFINITY;
    for (int i = 0; i < n; i++) {
        if (i == src) continue;
        CGRect c = windows[i].frame;
        double cx = CGRectGetMidX(c), cy = CGRectGetMidY(c);

        // Distance along the direction must be positive; drift across it is
        // penalised so a window straight ahead beats a closer diagonal one.
        double along, across;
        switch (dir) {
        case DIR_LEFT: along = sx - cx; across = fabs(cy - sy); break;
        case DIR_RIGHT: along = cx - sx; across = fabs(cy - sy); break;
        case DIR_UP: along = sy - cy; across = fabs(cx - sx); break;
        case DIR_DOWN: along = cy - sy; across = fabs(cx - sx); break;
        }
        if (along <= 1.0) continue;

        // Small z-order term so the visible window wins among stacked ones.
        double score = along + 2.0 * across + i;
        if (score < best_score) {
            best_score = score;
            best = i;
        }
    }

    if (best < 0) return 1;
    return focus_window(windows[best].pid, windows[best].wid) ? 0 : 1;
}

// Give display `disp` keyboard focus: raise its frontmost window, or failing
// that just hand it the menu bar.
static void focus_display(CGSConnectionID cid, const Display *disp)
{
    Window windows[MAX_WINDOWS];
    int n = visible_windows(windows, MAX_WINDOWS);
    for (int i = 0; i < n; i++) {
        CGPoint mid = CGPointMake(CGRectGetMidX(windows[i].frame), CGRectGetMidY(windows[i].frame));
        if (CGRectContainsPoint(disp->bounds, mid) && focus_window(windows[i].pid, windows[i].wid)) return;
    }
    if (SLSSetActiveMenuBarDisplayIdentifier) SLSSetActiveMenuBarDisplayIdentifier(cid, disp->uuid, disp->uuid);
}

// Make space `target` (0-based, global) visible on its display. Returns the
// index of that display.
static int show_space(const SpaceMap *map, int target)
{
    int d = map->display_of[target];
    const Display *disp = &map->displays[d];
    int current = visible_index(map, d);
    if (current < 0) die("could not find the visible space on that display");

    int steps = abs(target - current);
    if (steps > 0) {
        if (CGRectIsNull(disp->bounds)) die("could not find that display's bounds");
        // The swipe acts on the display under the cursor.
        ensure_cursor_on(disp->bounds);
        bool forward = target > current;
        for (int i = 0; i < steps; i++) swipe_one_space(forward);
        usleep(POST_SETTLE_USEC);
    }
    return d;
}

// The display holding the focused window: the AX focused window if it is on
// screen, else the frontmost ordinary window. The menu-bar display isn't
// reliable for this, since it can follow the cursor rather than focus.
static int focused_display(const SpaceMap *map)
{
    Window windows[MAX_WINDOWS];
    int n = visible_windows(windows, MAX_WINDOWS);
    if (n == 0) return map->active_display;

    CGWindowID focused = focused_window();
    int w = 0;
    for (int i = 0; i < n; i++)
        if (windows[i].wid == focused) w = i;

    CGPoint mid = CGPointMake(CGRectGetMidX(windows[w].frame), CGRectGetMidY(windows[w].frame));
    for (int d = 0; d < map->ndisplays; d++)
        if (CGRectContainsPoint(map->displays[d].bounds, mid)) return d;
    return map->active_display;
}

static int cmd_space(int n)
{
    CGSConnectionID cid = SLSMainConnectionID();
    SpaceMap map = load_spaces(cid);
    if (n < 1 || n > map.count) die("no such space");

    int from = focused_display(&map);
    int d = show_space(&map, n - 1);

    // Switching another display's space doesn't move focus there by itself,
    // and a space already visible on it needs no swipe at all.
    if (d != from) {
        const Display *disp = &map.displays[d];
        if (!CGRectIsNull(disp->bounds)) ensure_cursor_on(disp->bounds);
        focus_display(cid, disp);
    }
    return 0;
}

static int cmd_move(int n)
{
    // Without AppKit initialized the bridged move only half completes: the
    // window leaves its space but isn't placed on the target until its app
    // redraws. yabai and agate-wm always run with AppKit loaded.
    NSApplicationLoad();

    CGSConnectionID cid = SLSMainConnectionID();
    SpaceMap map = load_spaces(cid);
    if (n < 1 || n > map.count) die("no such space");
    uint64_t sid = map.ids[n - 1];

    pid_t pid = 0;
    CGWindowID wid = focused_window_of(&pid);
    CFArrayRef windows = wid ? window_array(wid) : NULL;
    uint64_t from = windows ? window_space(cid, windows) : 0;

    // Some apps report a focused window SkyLight doesn't manage (no space);
    // fall back to the app's frontmost ordinary window.
    if (!from && pid) {
        Window visible[MAX_WINDOWS];
        int count = visible_windows(visible, MAX_WINDOWS);
        for (int i = 0; i < count && !from; i++) {
            if (visible[i].pid != pid) continue;
            if (windows) CFRelease(windows);
            wid = visible[i].wid;
            windows = window_array(wid);
            from = window_space(cid, windows);
        }
    }
    if (!from) {
        if (windows) CFRelease(windows);
        die("no focused window");
    }
    if (from == sid) {
        CFRelease(windows);
        return 0;
    }

    bool ok = move_windows_bridged(windows, sid);
    if (!ok && SLSMoveWindowsToManagedSpace) {
        SLSMoveWindowsToManagedSpace(cid, windows, sid);
        ok = true;
    }
    if (!ok) {
        CFRelease(windows);
        die("this macOS version has no supported way to move windows between spaces");
    }

    // The bridged operation is asynchronous and is delivered from the main
    // queue, which only drains while the run loop runs. Spin it until the
    // window lands on the target space (agate-wm never notices this because it
    // always has a run loop going).
    bool moved = false;
    for (int i = 0; i < 50 && !moved; i++) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.02, false);
        moved = window_space(cid, windows) == sid;
    }
    CFRelease(windows);
    if (!moved) {
        fprintf(stderr, "windowbuddy: window %u did not move from space %llu to %llu\n", wid,
                (unsigned long long)from, (unsigned long long)sid);
        return 1;
    }

    // Follow the window: show its new space and focus it there.
    show_space(&map, n - 1);
    focus_window(pid, wid);
    return 0;
}

__attribute__((noreturn)) static void usage(void)
{
    fprintf(stderr,
            "usage: windowbuddy focus <left|right|up|down>\n"
            "       windowbuddy space <n>\n"
            "       windowbuddy move <n>\n");
    exit(2);
}

static int parse_space(const char *s)
{
    char *end;
    long n = strtol(s, &end, 10);
    if (*s == '\0' || *end != '\0' || n < 1 || n > MAX_SPACES) usage();
    return (int)n;
}

int main(int argc, char *argv[])
{
    if (argc != 3) usage();

    if (!AXIsProcessTrusted())
        fprintf(stderr, "windowbuddy: warning: Accessibility permission not granted\n");

    const char *cmd = argv[1], *arg = argv[2];

    if (strcmp(cmd, "focus") == 0) {
        if (!strcmp(arg, "left") || !strcmp(arg, "west")) return cmd_focus(DIR_LEFT);
        if (!strcmp(arg, "right") || !strcmp(arg, "east")) return cmd_focus(DIR_RIGHT);
        if (!strcmp(arg, "up") || !strcmp(arg, "north")) return cmd_focus(DIR_UP);
        if (!strcmp(arg, "down") || !strcmp(arg, "south")) return cmd_focus(DIR_DOWN);
        usage();
    }

    // Only the space commands need SkyLight; focus sticks to public APIs.
    load_skylight();
    if (strcmp(cmd, "space") == 0) return cmd_space(parse_space(arg));
    if (strcmp(cmd, "move") == 0) return cmd_move(parse_space(arg));
    usage();
}
