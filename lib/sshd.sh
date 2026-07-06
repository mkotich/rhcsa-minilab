#!/bin/bash

grade_sshd() {
    RESULT="PASS"

    OPTION=$(jq -r '.answer.option // empty' <<<"$OBJECT")
    EXPECTED=$(jq -r '.answer.value // empty' <<<"$OBJECT")

    [ -z "$OPTION" ] && return

    #
    # Read the effective sshd configuration.
    #
    ACTUAL=$(
        sshd -T 2>/dev/null |
            awk -v opt="$(echo "$OPTION" | tr '[:upper:]' '[:lower:]')" '
                tolower($1) == opt {
                    $1=""
                    sub(/^ /,"")
                    print
                    exit
                }
            '
    )

    [ "$ACTUAL" = "$EXPECTED" ] || RESULT="FAIL"
}
