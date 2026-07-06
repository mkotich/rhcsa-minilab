#!/bin/bash

grade_at() {
    RESULT="FAIL"

    COMMAND=$(jq -r '.answer.command' <<< "$OBJECT")

    while read JOB; do
        [ -z "$JOB" ] && continue

        if at -c "$JOB" 2> /dev/null | grep -F "$COMMAND" > /dev/null; then
            RESULT="PASS"
            return
        fi

    done < <(
        atq | awk '{print $1}'
    )
}
