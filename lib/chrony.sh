#!/bin/bash

grade_chrony() {
    RESULT="PASS"

    SERVER=$(jq -r '.answer.server // empty' <<<"$OBJECT")

    if [ -n "$SERVER" ]; then
        grep -Eq "^[[:space:]]*server[[:space:]]+${SERVER}([[:space:]]|$)" \
            /etc/chrony.conf || {
            RESULT="FAIL"
            return
        }
    fi
}
