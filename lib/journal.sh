#!/bin/bash

grade_journal()
{
    RESULT="PASS"

    COMMAND=$(echo "$OBJECT" | jq -r '.answer.command')
    OUTFILE=$(echo "$OBJECT" | jq -r '.answer.outfile')

    #
    # Output file must exist.
    #
    [ -f "$OUTFILE" ] || {
        RESULT="FAIL"
        return
    }

    EXPECTED=$(mktemp)

    eval "$COMMAND" >"$EXPECTED"

    diff -q "$EXPECTED" "$OUTFILE" >/dev/null 2>&1 \
        || RESULT="FAIL"

    rm -f "$EXPECTED"
}
