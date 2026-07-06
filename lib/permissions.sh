#!/bin/bash

prepare_permissions()
{
    mkdir -p /shared

    chown root:root /shared
    chmod 0755 /shared

    setfacl -b /shared 2>/dev/null || true
    setfacl -k /shared 2>/dev/null || true
}

grade_permissions()
{
    RESULT="PASS"

    EXPECTED_PATH=$(jq -r '.answer.path' <<<"$OBJECT")
    EXPECTED_MODE=$(jq -r '.answer.mode' <<<"$OBJECT")

    ACTUAL_MODE=$(stat -c %a "$EXPECTED_PATH" 2>/dev/null)

    [ "$ACTUAL_MODE" = "$EXPECTED_MODE" ] ||
        RESULT="FAIL"
}
