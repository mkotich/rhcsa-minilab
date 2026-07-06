#!/bin/bash

grade_process() {
    RESULT="PASS"

    PIDFILE=/var/lib/rhcsa-minilab/rhcsa-sleep.pid

    [ -f "$PIDFILE" ] || {
        RESULT="FAIL"
        return
    }

    PID=$(cat "$PIDFILE")

    #
    # Process must still exist.
    #
    ps -p "$PID" > /dev/null 2>&1 || {
        RESULT="FAIL"
        return
    }

    EXPECTED=$(jq -r '.answer.nice' <<< "$OBJECT")
    CURRENT=$(ps -o ni= -p "$PID" | xargs)

    [ "$CURRENT" = "$EXPECTED" ] || RESULT="FAIL"
}
