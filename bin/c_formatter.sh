#!/usr/bin/env bash

find "$@" -type f \( \
    -iname "*.c" -o \
    -iname "*.cpp" -o \
    -iname "*.h" -o \
    -iname "*.cu" -o \
    -iname "*.upc" \
    \) \
    -exec clang-format -i -style=WebKit {} \+
