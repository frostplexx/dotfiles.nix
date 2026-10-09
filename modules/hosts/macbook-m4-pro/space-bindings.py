"""Resolve Dock "Assign To" bindings from (display, desktop index) to Space UUIDs.

Usage: space-bindings.py BINDINGS_JSON
BINDINGS_JSON maps bundle id -> {"display": "external" | "builtin", "space": n}
(1-based). "external" falls back to the built-in panel when undocked, and
"builtin" to the external one on a lid-closed setup, mirroring agate-wm.

Writes com.apple.spaces app-bindings and restarts the Dock only when the
resolved bindings differ from what is already set.
"""

import ctypes
import ctypes.util
import json
import plistlib
import subprocess
import sys

cg = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreGraphics"))
cf = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreFoundation"))
cs = ctypes.cdll.LoadLibrary(ctypes.util.find_library("ColorSync"))
cg.CGMainDisplayID.restype = ctypes.c_uint32
cg.CGDisplayIsBuiltin.argtypes = [ctypes.c_uint32]
cs.CGDisplayCreateUUIDFromDisplayID.argtypes = [ctypes.c_uint32]
cs.CGDisplayCreateUUIDFromDisplayID.restype = ctypes.c_void_p
cf.CFUUIDCreateString.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
cf.CFUUIDCreateString.restype = ctypes.c_void_p
cf.CFStringGetCString.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_uint32]
cf.CFRelease.argtypes = [ctypes.c_void_p]


def display_uuid(display_id):
    uuid = cs.CGDisplayCreateUUIDFromDisplayID(display_id)
    string = cf.CFUUIDCreateString(None, uuid)
    buf = ctypes.create_string_buffer(64)
    cf.CFStringGetCString(string, buf, len(buf), 0x08000100)  # UTF-8
    cf.CFRelease(string)
    cf.CFRelease(uuid)
    return buf.value.decode()


def active_displays():
    """Map display UUID -> is built-in, for currently connected displays."""
    ids = (ctypes.c_uint32 * 16)()
    count = ctypes.c_uint32()
    cg.CGGetActiveDisplayList(16, ids, ctypes.byref(count))
    return {display_uuid(i): bool(cg.CGDisplayIsBuiltin(i)) for i in ids[: count.value]}


def defaults_export(domain):
    out = subprocess.run(["defaults", "export", domain, "-"], capture_output=True, check=True).stdout
    return plistlib.loads(out)


def main():
    wanted = json.loads(sys.argv[1])
    displays = active_displays()
    main_uuid = display_uuid(cg.CGMainDisplayID())

    # Ordered desktop UUIDs per connected display. The Dock calls the main
    # display "Main" instead of using its UUID.
    spaces = {"builtin": None, "external": None}
    monitors = defaults_export("com.apple.spaces")["SpacesDisplayConfiguration"]["Management Data"]["Monitors"]
    for monitor in monitors:
        ident = monitor.get("Display Identifier")
        ident = main_uuid if ident == "Main" else ident
        if ident not in displays or not monitor.get("Spaces"):
            continue
        kind = "builtin" if displays[ident] else "external"
        if spaces[kind] is None:
            spaces[kind] = [s.get("uuid", "") for s in monitor["Spaces"] if s.get("type") == 0]
    spaces["external"] = spaces["external"] or spaces["builtin"]
    spaces["builtin"] = spaces["builtin"] or spaces["external"]

    bindings = {}
    for app, target in wanted.items():
        desktops = spaces[target["display"]] or []
        if target["space"] > len(desktops):
            print(f"space-bindings: {app}: {target['display']} has only {len(desktops)} desktop(s), skipping", file=sys.stderr)
            continue
        bindings[app.lower()] = desktops[target["space"] - 1]

    if defaults_export("com.apple.spaces").get("app-bindings", {}) == bindings:
        return
    entries = [arg for app, uuid in bindings.items() for arg in (app, uuid)]
    subprocess.run(["defaults", "delete", "com.apple.spaces", "app-bindings"], capture_output=True)
    subprocess.run(["defaults", "write", "com.apple.spaces", "app-bindings", "-dict", *entries], check=True)
    subprocess.run(["killall", "Dock"], capture_output=True)
    print(f"space-bindings: updated {len(bindings)} binding(s)")


if __name__ == "__main__":
    main()
