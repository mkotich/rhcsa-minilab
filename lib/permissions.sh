#!/bin/bash

prepare_permissions()
{
    mkdir -p /public /shared /projects

    chown root:root /public /shared /projects

    chmod 0777 /public
    chmod 0755 /shared
    chmod 0755 /projects

    setfacl -b /public 2>/dev/null || true
    setfacl -b /shared 2>/dev/null || true
    setfacl -b /projects 2>/dev/null || true

    setfacl -k /public 2>/dev/null || true
    setfacl -k /shared 2>/dev/null || true
    setfacl -k /projects 2>/dev/null || true
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
