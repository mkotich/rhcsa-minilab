#!/bin/bash

FAIL=0

for f in prepare/*.sh
do
    GROUP=$(basename "$f" .sh)

    grep -q "^prepare_${GROUP}()" "$f" || {
        echo "Missing prepare_${GROUP}() in $f"
        FAIL=1
    }
done

exit $FAIL
