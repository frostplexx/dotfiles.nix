#!/usr/bin/env bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  system_profiler SPDisplaysDataType | grep Resolution | awk '{print "{\"width\": " $2 ", \"height\": " $4 "}"}' | head -n 1
else
  xrandr | grep ' connected' | grep -o '[0-9]*x[0-9]*' | awk -F 'x' '{print "{\"width\": " $1 ", \"height\": " $2 "}"}' | head -n 1
fi
