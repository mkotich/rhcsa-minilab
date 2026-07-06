#!/bin/bash

grade_firewall()
{
    RESULT="PASS"

    EXPECTED_SERVICE=$(jq -r '.answer.service // empty' <<<"$OBJECT")
    EXPECTED_PORT=$(jq -r '.answer.port // empty' <<<"$OBJECT")
    EXPECTED_RICH_RULE=$(jq -r '.answer.rich_rule // empty' <<<"$OBJECT")

    if [ -n "$EXPECTED_SERVICE" ]
    then
        firewall-cmd --permanent --list-services |
            grep -qw "$EXPECTED_SERVICE" ||
            RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_PORT" ]
    then
        firewall-cmd --permanent --list-ports |
            grep -qw "$EXPECTED_PORT" ||
            RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_RICH_RULE" ]
    then
        firewall-cmd --permanent --list-rich-rules |
            grep -Fxq "$EXPECTED_RICH_RULE" ||
            RESULT="FAIL"
    fi
}
