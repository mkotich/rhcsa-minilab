#!/bin/bash

grade_networking()
{
    RESULT="PASS"

    HOSTNAME=$(jq -r '.answer.hostname // empty' <<<"$OBJECT")
    ADDRESS=$(jq -r '.answer.address // empty' <<<"$OBJECT")
    SECONDARY_DNS=$(jq -r '.answer.secondary_dns // empty' <<<"$OBJECT")
    SEARCH_DOMAIN=$(jq -r '.answer.search_domain // empty' <<<"$OBJECT")

    if [ -n "$HOSTNAME" ]
    then
        [ "$(hostnamectl --static)" = "$HOSTNAME" ] || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$ADDRESS" ]
    then
        ip addr | grep -qw "$ADDRESS" || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$SECONDARY_DNS" ]
    then
        nmcli device show |
            grep -Fq "$SECONDARY_DNS" ||
            RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$SEARCH_DOMAIN" ]
    then
        nmcli device show |
            grep -Fq "$SEARCH_DOMAIN" ||
            RESULT="FAIL"
    fi
}
