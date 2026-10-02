// Windows: on-screen window list, Accessibility focus, cursor.
#pragma once

#include "util.h"

#define MAX_WINDOWS 256

typedef struct {
    CGWindowID wid;
    pid_t pid;
    CGRect frame;
} Window;

// Ordinary on-screen windows on the visible spaces, front to back.
int visible_windows(Window *out, int max);

// The focused window's id, or 0; `pid_out` (optional) receives the focused app.
CGWindowID focused_window_of(pid_t *pid_out);
CGWindowID focused_window(void);

// Make `pid` frontmost and raise its window `wid`. False if the window isn't found.
bool focus_window(pid_t pid, CGWindowID wid);

// Warp the cursor to the middle of `bounds` unless it is already on it.
void ensure_cursor_on(CGRect bounds);
