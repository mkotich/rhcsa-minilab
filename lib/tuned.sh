#!/bin/bash

grade_tuned()
{
    RESULT="PASS"

    SERVICE=$(jq -r '.answer.service // empty' <<<"$OBJECT")
    PROFILE=$(jq -r '.answer.profile // empty' <<<"$OBJECT")

    #
    # Service installed, enabled, and running.
    #
    if [ -n "$SERVICE" ]
    then
        rpm -q tuned > /dev/null 2>&1 || {
            RESULT="FAIL"
            return
        }

        systemctl is-enabled "$SERVICE" > /dev/null 2>&1 || {
            RESULT="FAIL"
            return
        }

        systemctl is-active "$SERVICE" > /dev/null 2>&1 || {
            RESULT="FAIL"
            return
        }
    fi

    #
    # Active tuned profile.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$PROFILE" ]
    then
        CURRENT=$(tuned-adm active 2> /dev/null |
            sed -n 's/^Current active profile: //p')

        [ "$CURRENT" = "$PROFILE" ] || RESULT="FAIL"
    fi
}
