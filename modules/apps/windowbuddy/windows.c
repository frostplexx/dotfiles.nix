#include "windows.h"

// Not public in any header, but exported by HIServices.
extern AXError _AXUIElementGetWindow(AXUIElementRef element, CGWindowID *wid);

// A hung app would otherwise block each AX call for the default ~6 s, which
// stalls the hotkey that ran us.
#define AX_TIMEOUT_SEC 1.0f

int visible_windows(Window *out, int max)
{
    CFArrayRef list = CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    if (!list) return 0;

    int n = 0;
    for (CFIndex i = 0; i < CFArrayGetCount(list) && n < max; i++) {
        CFDictionaryRef info = CFArrayGetValueAtIndex(list, i);
        if (dict_i64(info, "kCGWindowLayer") != 0) continue;

        CFNumberRef alpha = CFDictionaryGetValue(info, kCGWindowAlpha);
        double a = 1.0;
        if (alpha) CFNumberGetValue(alpha, kCFNumberDoubleType, &a);
        if (a <= 0.0) continue;

        CGRect frame;
        CFDictionaryRef bounds = CFDictionaryGetValue(info, kCGWindowBounds);
        if (!bounds || !CGRectMakeWithDictionaryRepresentation(bounds, &frame)) continue;
        if (frame.size.width < 50 || frame.size.height < 50) continue;

        out[n++] = (Window){
            .wid = (CGWindowID)dict_i64(info, "kCGWindowNumber"),
            .pid = (pid_t)dict_i64(info, "kCGWindowOwnerPID"),
            .frame = frame,
        };
    }
    CFRelease(list);
    return n;
}

CGWindowID focused_window_of(pid_t *pid_out)
{
    AXUIElementRef system = AXUIElementCreateSystemWide();
    AXUIElementRef app = NULL, win = NULL;
    CGWindowID wid = 0;

    AXUIElementSetMessagingTimeout(system, AX_TIMEOUT_SEC);
    if (AXUIElementCopyAttributeValue(system, kAXFocusedApplicationAttribute, (CFTypeRef *)&app) == kAXErrorSuccess) {
        if (pid_out) AXUIElementGetPid(app, pid_out);
        AXUIElementSetMessagingTimeout(app, AX_TIMEOUT_SEC);
        if (AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute, (CFTypeRef *)&win) == kAXErrorSuccess)
            _AXUIElementGetWindow(win, &wid);
    }

    if (win) CFRelease(win);
    if (app) CFRelease(app);
    CFRelease(system);
    return wid;
}

CGWindowID focused_window(void)
{
    return focused_window_of(NULL);
}

bool focus_window(pid_t pid, CGWindowID wid)
{
    AXUIElementRef app = AXUIElementCreateApplication(pid);
    CFArrayRef windows = NULL;
    bool ok = false;

    AXUIElementSetMessagingTimeout(app, AX_TIMEOUT_SEC);
    if (AXUIElementCopyAttributeValue(app, kAXWindowsAttribute, (CFTypeRef *)&windows) == kAXErrorSuccess) {
        for (CFIndex i = 0; i < CFArrayGetCount(windows); i++) {
            AXUIElementRef win = CFArrayGetValueAtIndex(windows, i);
            CGWindowID id = 0;
            if (_AXUIElementGetWindow(win, &id) != kAXErrorSuccess || id != wid) continue;

            // Raising a window while another app is frontmost doesn't move
            // focus, so bring the app forward first.
            AXUIElementSetAttributeValue(app, kAXFrontmostAttribute, kCFBooleanTrue);
            AXUIElementSetAttributeValue(win, kAXMainAttribute, kCFBooleanTrue);
            AXUIElementPerformAction(win, kAXRaiseAction);
            ok = true;
            break;
        }
        CFRelease(windows);
    }
    CFRelease(app);
    return ok;
}

void ensure_cursor_on(CGRect bounds)
{
    CGEventRef ev = CGEventCreate(NULL);
    CGPoint cursor = ev ? CGEventGetLocation(ev) : CGPointZero;
    if (ev) CFRelease(ev);
    if (CGRectContainsPoint(bounds, cursor)) return;

    CGWarpMouseCursorPosition(CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)));
    // A warp suppresses real mouse input briefly unless re-associated.
    CGAssociateMouseAndMouseCursorPosition(true);
}
