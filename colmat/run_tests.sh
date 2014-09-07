#!/bin/bash

function Try {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
                exit $status
    fi
}

for TF in *.t; do Try perl $TF; done
