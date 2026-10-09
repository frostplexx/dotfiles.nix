// Synthetic Dock swipe, used to switch spaces.
#pragma once

#include "util.h"

// The window server validates a synthetic event's sender when it processes the
// event, not when it is posted. If we exit first, the trailing "ended" phase is
// rejected ("Sender is prohibited from synthesizing events") and the system is
// left mid-swipe with the pointer captured. So stay connected this long after
// the last swipe. agate-wm never hits this because it is a long-lived daemon.
#define POST_SETTLE_USEC (150 * 1000)

// Swipe one space on the display under the cursor; forward == true moves to
// the next (higher-numbered) space. Wait POST_SETTLE_USEC before exiting.
void swipe_one_space(bool forward);
