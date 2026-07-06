#!/bin/bash

grade_find()
{
    RESULT="PASS"

    SCRIPT=$(jq -r '.answer.script' <<<"$OBJECT")

    #
    # Student hasn't created the script yet.
    #
    [ -x "$SCRIPT" ] || {
        RESULT="FAIL"
        return
    }

    while read -r TEST
    do
        EXPECTED=$(jq -r '.stdout_command' <<<"$TEST")

        diff -u \
            <("$SCRIPT") \
            <(bash -c "$EXPECTED") >/dev/null || {
            RESULT="FAIL"
            return
        }

    done < <(
        jq -c '.answer.tests[]' <<<"$OBJECT"
    )
}
