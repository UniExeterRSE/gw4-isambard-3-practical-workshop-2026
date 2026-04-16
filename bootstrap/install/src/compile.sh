#!/bin/bash

# Check if filename argument is provided
if [[ $# -ne 1 ]]; then
    echo 'Usage: compile.sh FILENAME' >&2
    exit 1
fi

FILENAME="${1}"

# Check if the file exists
if [[ ! -f ${FILENAME} ]]; then
    echo "Error: File '${FILENAME}' not found" >&2
    exit 1
fi

# Get the directory of the input file for relative path resolution
BASEDIR="$(dirname "${FILENAME}")"

# Process the file line by line
while IFS= read -r line; do
    # Check if line matches the pattern ^source ${FILEPATH}$
    if [[ ${line} =~ ^source\ (.+)$ ]]; then
        # Extract the filepath
        FILEPATH="${BASH_REMATCH[1]}"

        FULLPATH="${BASEDIR}/${FILEPATH}"

        # Check if the referenced file exists
        if [[ -f ${FULLPATH} ]]; then
            # Include the contents of the file
            cat "${FULLPATH}"
        else
            echo "Error: Referenced file '${FULLPATH}' not found" >&2
            exit 1
        fi
    else
        # Print the line as-is
        echo "${line}"
    fi
done < "${FILENAME}"
