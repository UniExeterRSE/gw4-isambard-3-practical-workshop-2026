#!/usr/bin/env bash

# Find all shell scripts, normalize variable usage and spacing, then format with shfmt
find "$@" -type f -name '*.sh' \
    -exec sed -i -E \
    -e 's/\$([a-zA-Z_][a-zA-Z0-9_]*|[0-9]+)/${\1}/g' \
    -e 's/([^[])\[ ([^]]+) \]/\1[[ \2 ]]/g' \
    {} + \
    -exec shfmt \
    --write \
    --simplify \
    --indent 4 \
    --case-indent \
    --space-redirects \
    {} +
