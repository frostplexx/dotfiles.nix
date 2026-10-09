// Since macOS 27 the space-swipe recognizer reads the gesture from the
// IOHIDEvent backing a CGEvent, which synthetic events lack. The workaround
// (FasterSwiper / yabai #2781, via agate-wm) is to inject private field 4205
// (an IOHIDSystemQueueElement) into the serialized CGEvent and deserialize it.

#include "gesture.h"

#include <float.h>
#include <mach/mach_time.h>
#include <string.h>

enum { PHASE_BEGAN = 1, PHASE_ENDED = 4 };

#define kCGSEventTypeField ((CGEventField)55)
#define kCGEventGestureHIDType ((CGEventField)110)
#define kCGEventGestureSwipeMotion ((CGEventField)123)
#define kCGEventGestureSwipeProgress ((CGEventField)124)
#define kCGEventGestureSwipeVelocityX ((CGEventField)129)
#define kCGEventGestureSwipeVelocityY ((CGEventField)130)
#define kCGEventGesturePhase ((CGEventField)132)
#define kCGEventSourceUnixProcessIDField ((CGEventField)41)
#define kCGSEventDockControl 30
#define kIOHIDEventTypeDockSwipe 23
#define kCGGestureMotionHorizontal 1

// Large enough that the switch is effectively instant.
#define SWIPE_VELOCITY 9999.0

// Field 4205 payload: 4-byte tag + 28-byte header + 40-byte gesture + 28-byte velocity.
#define FIELD_4205_MAX (4 + 28 + 40 + 28)

static void put_le32(uint8_t *b, uint32_t v)
{
    b[0] = (uint8_t)v; b[1] = (uint8_t)(v >> 8); b[2] = (uint8_t)(v >> 16); b[3] = (uint8_t)(v >> 24);
}

static void put_le64(uint8_t *b, uint64_t v)
{
    put_le32(b, (uint32_t)v);
    put_le32(b + 4, (uint32_t)(v >> 32));
}

static void put_le16(uint8_t *b, uint16_t v)
{
    b[0] = (uint8_t)v; b[1] = (uint8_t)(v >> 8);
}

// 16.16 fixed point; keeps the sign of tiny non-zero values.
static int32_t fixed16(double v)
{
    int32_t f = (int32_t)(v * 65536.0);
    if (f == 0 && v != 0.0) return v > 0 ? 1 : -1;
    return f;
}

// IOHIDEventBase: size, type, options (phase in bits 24-31), depth, 3 reserved.
static uint8_t *put_event_base(uint8_t *b, uint32_t size, uint32_t type, uint32_t options, uint8_t depth)
{
    put_le32(b, size);
    put_le32(b + 4, type);
    put_le32(b + 8, options);
    b[12] = depth; b[13] = b[14] = b[15] = 0;
    return b + 16;
}

static void post_swipe_phase(int phase, bool forward, double progress, double velocity)
{
    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef ev = CGEventCreate(src);
    if (src) CFRelease(src);
    if (!ev) return;

    CGEventSetIntegerValueField(ev, kCGSEventTypeField, kCGSEventDockControl);
    CGEventSetIntegerValueField(ev, kCGEventGestureHIDType, kIOHIDEventTypeDockSwipe);
    CGEventSetIntegerValueField(ev, kCGEventGesturePhase, phase);
    CGEventSetDoubleValueField(ev, kCGEventGestureSwipeProgress, progress);
    CGEventSetIntegerValueField(ev, kCGEventGestureSwipeMotion, kCGGestureMotionHorizontal);
    CGEventSetDoubleValueField(ev, kCGEventGestureSwipeVelocityX, velocity);
    CGEventSetDoubleValueField(ev, kCGEventGestureSwipeVelocityY, 0.0);
    CGEventSetIntegerValueField(ev, kCGEventSourceUnixProcessIDField, 0);

    CFDataRef data = CGEventCreateData(NULL, ev);
    uint64_t ts = CGEventGetTimestamp(ev);
    CFRelease(ev);
    if (!data) return;

    const uint8_t *raw = CFDataGetBytePtr(data);
    size_t len = (size_t)CFDataGetLength(data);
    uint8_t buf[4096];
    // The copied fields never exceed len, so this leaves room for field 4205.
    if (len < 4 || len > sizeof(buf) - FIELD_4205_MAX) {
        CFRelease(data);
        return;
    }

    // Copy the version header and every field except a pre-existing 4205.
    memcpy(buf, raw, 4);
    size_t out = 4;
    for (size_t i = 4; i + 4 <= len;) {
        uint16_t size_words = (uint16_t)(raw[i] << 8 | raw[i + 1]);
        uint16_t tag = (uint16_t)(raw[i + 2] << 8 | raw[i + 3]);
        uint16_t field = tag & 0x3FFF;
        size_t payload;
        switch (tag >> 14) {
        case 0: payload = size_words == 1 ? 8 : ((size_t)size_words + 3) & ~(size_t)3; break;
        case 2: payload = 0; break;
        default: payload = (size_t)size_words * 4; break;
        }
        if (i + 4 + payload > len) break;
        if (field != 4205) {
            memcpy(buf + out, raw + i, 4 + payload);
            out += 4 + payload;
        }
        i += 4 + payload;
    }
    CFRelease(data);

    if (ts == 0) ts = mach_absolute_time();
    bool has_velocity = velocity != 0.0 || phase == PHASE_ENDED;
    uint16_t payload_size = has_velocity ? 96 : 68;
    // Swipe mask follows the finger direction: fingers left (0x4) = next space.
    uint32_t swipe_mask = forward ? 0x4 : 0x8;
    uint32_t phase_opts = (uint32_t)(phase & 0xFF) << 24;

    // Field tag: big-endian byte count + field id 4205 (0x106D).
    uint8_t *p = buf + out;
    p[0] = (uint8_t)(payload_size >> 8); p[1] = (uint8_t)(payload_size & 0xFF); p[2] = 0x10; p[3] = 0x6D;
    p += 4;

    // IOHIDSystemQueueElement header (28 bytes).
    put_le64(p, ts);
    put_le64(p + 8, 0x100003416); // horizontal gesture registry entry
    put_le32(p + 16, 0);          // options
    put_le32(p + 20, 0);          // attribute length
    put_le32(p + 24, has_velocity ? 2 : 1);
    p += 28;

    // IOHIDFluidTouchGestureData (40 bytes).
    p = put_event_base(p, 40, 23, phase_opts, 0);
    put_le32(p, 0); put_le32(p + 4, 0); put_le32(p + 8, 0); // position xyz
    put_le32(p + 12, swipe_mask);
    put_le16(p + 16, 1); // kIOHIDGestureMotionHorizontalX
    put_le16(p + 18, 3); // kIOHIDGestureFlavorDockPrimary
    put_le32(p + 20, (uint32_t)fixed16(progress));
    p += 24;

    if (has_velocity) {
        // IOHIDVelocityEventData (28 bytes).
        p = put_event_base(p, 28, 9, 0, 1);
        put_le32(p, (uint32_t)fixed16(velocity));
        put_le32(p + 4, 0);
        put_le32(p + 8, 0);
        p += 12;
    }
    out = (size_t)(p - buf);

    CFDataRef patched = CFDataCreate(NULL, buf, (CFIndex)out);
    CGEventRef new_ev = CGEventCreateFromData(NULL, patched);
    CFRelease(patched);
    if (!new_ev) return;
    CGEventPost(kCGSessionEventTap, new_ev);
    CFRelease(new_ev);
}

void swipe_one_space(bool forward)
{
    // Near-zero progress means no visible drag; the velocity on "ended" carries
    // the recognizer the rest of the way to the adjacent space.
    double progress = forward ? -FLT_TRUE_MIN : FLT_TRUE_MIN;
    double sign = forward ? -1.0 : 1.0;
    post_swipe_phase(PHASE_BEGAN, forward, progress, 0.0);
    post_swipe_phase(PHASE_ENDED, forward, progress, sign * SWIPE_VELOCITY);
}
