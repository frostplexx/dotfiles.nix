// Shared includes and small helpers.
#pragma once

#include <ApplicationServices/ApplicationServices.h>
#include <stdbool.h>
#include <stdint.h>

// Print `windowbuddy: <msg>` to stderr and exit(1).
__attribute__((noreturn)) void die(const char *msg);

// Integer value for `key` in a CF dictionary, or 0 if missing or not a number.
int64_t dict_i64(CFDictionaryRef dict, const char *key);
