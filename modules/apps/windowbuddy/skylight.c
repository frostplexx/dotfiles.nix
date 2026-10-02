#include "skylight.h"

#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <string.h>

#define SKYLIGHT_PATH "/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight"

CGSConnectionID (*SLSMainConnectionID)(void);
CFArrayRef (*SLSCopyManagedDisplaySpaces)(CGSConnectionID cid);
CFStringRef (*SLSCopyActiveMenuBarDisplayIdentifier)(CGSConnectionID cid);
uint64_t (*SLSManagedDisplayGetCurrentSpace)(CGSConnectionID cid, CFStringRef display);
void (*SLSMoveWindowsToManagedSpace)(CGSConnectionID cid, CFArrayRef windows, uint64_t sid);
CFArrayRef (*SLSCopySpacesForWindows)(CGSConnectionID cid, int mask, CFArrayRef windows);
void (*SLSSetActiveMenuBarDisplayIdentifier)(CGSConnectionID cid, CFStringRef display, CFStringRef display2);

void load_skylight(void)
{
    void *skylight = dlopen(SKYLIGHT_PATH, RTLD_LAZY);
    if (!skylight) die("could not load SkyLight.framework");

#define LOAD(name) \
    if (!(*(void **)&name = dlsym(skylight, #name))) die("missing SkyLight symbol " #name)
    LOAD(SLSMainConnectionID);
    LOAD(SLSCopyManagedDisplaySpaces);
    LOAD(SLSCopyActiveMenuBarDisplayIdentifier);
    LOAD(SLSManagedDisplayGetCurrentSpace);
#undef LOAD
    // Pre-Tahoe path for moving windows; may be absent on newer releases.
    *(void **)&SLSMoveWindowsToManagedSpace = dlsym(skylight, "SLSMoveWindowsToManagedSpace");
    *(void **)&SLSCopySpacesForWindows = dlsym(skylight, "SLSCopySpacesForWindows");
    *(void **)&SLSSetActiveMenuBarDisplayIdentifier = dlsym(skylight, "SLSSetActiveMenuBarDisplayIdentifier");
}

// The SkyLight function macOS 26+ requires for cross-space moves is a C++
// file-local, so dlsym can't see it. Walk SkyLight's LC_SYMTAB instead (same
// trick as yabai's macho_dlsym.h). Only the system SkyLight image at its fixed
// path is searched.
static void *skylight_private_symbol(const char *name)
{
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *img = _dyld_get_image_name(i);
        if (!img || strcmp(img, SKYLIGHT_PATH) != 0) continue;

        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(i);
        if (!header || header->magic != MH_MAGIC_64) return NULL;
        intptr_t slide = _dyld_get_image_vmaddr_slide(i);
        const struct segment_command_64 *linkedit = NULL;
        const struct symtab_command *symtab = NULL;

        uintptr_t cmd_addr = (uintptr_t)header + sizeof(*header);
        for (uint32_t c = 0; c < header->ncmds; c++) {
            const struct load_command *cmd = (const struct load_command *)cmd_addr;
            if (cmd->cmd == LC_SEGMENT_64) {
                const struct segment_command_64 *seg = (const struct segment_command_64 *)cmd;
                if (strcmp(seg->segname, SEG_LINKEDIT) == 0) linkedit = seg;
            } else if (cmd->cmd == LC_SYMTAB) {
                symtab = (const struct symtab_command *)cmd;
            }
            cmd_addr += cmd->cmdsize;
        }
        if (!linkedit || !symtab) return NULL;

        uintptr_t base = (uintptr_t)(linkedit->vmaddr - linkedit->fileoff) + (uintptr_t)slide;
        const char *strs = (const char *)(base + symtab->stroff);
        const struct nlist_64 *syms = (const struct nlist_64 *)(base + symtab->symoff);
        for (uint32_t s = 0; s < symtab->nsyms; s++) {
            if (syms[s].n_un.n_strx >= symtab->strsize) continue;
            if (strcmp(strs + syms[s].n_un.n_strx, name) == 0)
                return (void *)(uintptr_t)(syms[s].n_value + (uint64_t)slide);
        }
        return NULL;
    }
    return NULL;
}

CFArrayRef window_array(CGWindowID wid)
{
    // SkyLight wants Int32 CFNumbers here; Int64 entries are silently dropped.
    int32_t wid32 = (int32_t)wid;
    CFNumberRef num = CFNumberCreate(NULL, kCFNumberSInt32Type, &wid32);
    CFArrayRef windows = CFArrayCreate(NULL, (const void **)&num, 1, &kCFTypeArrayCallBacks);
    CFRelease(num);
    return windows;
}

uint64_t window_space(CGSConnectionID cid, CFArrayRef windows)
{
    if (!SLSCopySpacesForWindows) return 0;
    // 0x7 = user, fullscreen and system spaces; a wider mask reports the
    // active space for any window.
    CFArrayRef spaces = SLSCopySpacesForWindows(cid, 0x7, windows);
    uint64_t sid = 0;
    if (spaces) {
        if (CFArrayGetCount(spaces) > 0)
            CFNumberGetValue(CFArrayGetValueAtIndex(spaces, 0), kCFNumberSInt64Type, &sid);
        CFRelease(spaces);
    }
    return sid;
}

bool move_windows_bridged(CFArrayRef windows, uint64_t sid)
{
    void (*perform)(id) = (void (*)(id))skylight_private_symbol(
        "__ZL54SLSPerformAsynchronousBridgedWindowManagementOperationP47SLSAsynchronousBridgedWindowManagementOperation");
    Class cls = objc_getClass("SLSBridgedMoveWindowsToManagedSpaceOperation");
    if (!perform || !cls) return false;

    id op = ((id (*)(Class, SEL))objc_msgSend)(cls, sel_registerName("alloc"));
    op = ((id (*)(id, SEL, CFArrayRef, uint64_t))objc_msgSend)(op, sel_registerName("initWithWindows:spaceID:"), windows, sid);
    if (!op) return false;
    perform(op);
    ((void (*)(id, SEL))objc_msgSend)(op, sel_registerName("release"));
    return true;
}
