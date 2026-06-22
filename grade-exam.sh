#!/bin/bash

STATE=/home/student/exam-state.json

PASS_COUNT=0
IMPLEMENTED_COUNT=0
TOTAL_COUNT=0

echo
echo "================================================="
echo "RHCSA MiniLab Results"
echo "================================================="
echo

while IFS= read -r OBJECT
do
    ID=$(echo "$OBJECT" | jq -r '.id')
    CATEGORY=$(echo "$OBJECT" | jq -r '.category')

    RESULT="NOT IMPLEMENTED"

    #
    # Users
    #
    if [ "$CATEGORY" = "users" ]
    then
        RESULT="PASS"

        EXPECTED_GROUP_NAME=$(echo "$OBJECT" | jq -r '.answer.group_name // empty')
        EXPECTED_GID=$(echo "$OBJECT" | jq -r '.answer.gid // empty')
        EXPECTED_USERNAME=$(echo "$OBJECT" | jq -r '.answer.username // empty')
        EXPECTED_UID=$(echo "$OBJECT" | jq -r '.answer.uid // empty')
        EXPECTED_SHELL=$(echo "$OBJECT" | jq -r '.answer.shell // empty')
        EXPECTED_SUPP_GROUP=$(echo "$OBJECT" | jq -r '.answer.supplementary_group // empty')

        if [ -n "$EXPECTED_GROUP_NAME" ]
        then
            GROUP_ENTRY=$(getent group "$EXPECTED_GROUP_NAME") || RESULT="FAIL"

            if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_GID" ]
            then
                ACTUAL_GID=$(echo "$GROUP_ENTRY" | cut -d: -f3)
                [ "$ACTUAL_GID" = "$EXPECTED_GID" ] || RESULT="FAIL"
            fi
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_USERNAME" ]
        then
            id "$EXPECTED_USERNAME" >/dev/null 2>&1 || RESULT="FAIL"

            if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_UID" ]
            then
                ACTUAL_UID=$(id -u "$EXPECTED_USERNAME")
                [ "$ACTUAL_UID" = "$EXPECTED_UID" ] || RESULT="FAIL"
            fi

            if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SHELL" ]
            then
                ACTUAL_SHELL=$(getent passwd "$EXPECTED_USERNAME" | cut -d: -f7)
                [ "$ACTUAL_SHELL" = "$EXPECTED_SHELL" ] || RESULT="FAIL"
            fi

            if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SUPP_GROUP" ]
            then
                id -nG "$EXPECTED_USERNAME" | grep -qw "$EXPECTED_SUPP_GROUP" || RESULT="FAIL"
            fi
        fi
    fi

    #
    # Storage v1
    #
    if [ "$CATEGORY" = "storage" ]
    then
        RESULT="PASS"

        EXPECTED_VG=$(echo "$OBJECT" | jq -r '.answer.volume_group // empty')
        EXPECTED_LV=$(echo "$OBJECT" | jq -r '.answer.logical_volume // empty')
        EXPECTED_MOUNT=$(echo "$OBJECT" | jq -r '.answer.mountpoint // empty')
        EXPECTED_FS=$(echo "$OBJECT" | jq -r '.answer.filesystem // empty')
        EXPECTED_PARTITION=$(echo "$OBJECT" | jq -r '.answer.partition // empty')

        if [ -n "$EXPECTED_VG" ]
        then
            vgs "$EXPECTED_VG" >/dev/null 2>&1 || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_LV" ]
        then
            lvs "$EXPECTED_VG/$EXPECTED_LV" >/dev/null 2>&1 || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_PARTITION" ]
        then
            lsblk "$EXPECTED_PARTITION" >/dev/null 2>&1 || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_MOUNT" ]
        then
            findmnt "$EXPECTED_MOUNT" >/dev/null 2>&1 || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ "$EXPECTED_FS" = "swap" ]
        then
            swapon --show | grep -q "$EXPECTED_LV" || RESULT="FAIL"
        fi
    fi

    #
    # Services v1
    #
    if [ "$CATEGORY" = "services" ]
    then
        RESULT="PASS"

        EXPECTED_PACKAGE=$(echo "$OBJECT" | jq -r '.answer.package // empty')
        EXPECTED_SERVICE=$(echo "$OBJECT" | jq -r '.answer.service // empty')

        if [ -n "$EXPECTED_PACKAGE" ]
        then
            rpm -q "$EXPECTED_PACKAGE" >/dev/null 2>&1 || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SERVICE" ]
        then
            systemctl is-enabled "$EXPECTED_SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SERVICE" ]
        then
            systemctl is-active "$EXPECTED_SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
        fi
    fi

    printf "%-20s %s\n" "$ID" "$RESULT"

    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    if [ "$RESULT" != "NOT IMPLEMENTED" ]
    then
        IMPLEMENTED_COUNT=$((IMPLEMENTED_COUNT + 1))

        if [ "$RESULT" = "PASS" ]
        then
            PASS_COUNT=$((PASS_COUNT + 1))
        fi
    fi

done < <(
    jq -c '.[]' "$STATE"
)

echo

printf "%-20s %s/%s\n" "Implemented" "$IMPLEMENTED_COUNT" "$TOTAL_COUNT"

if [ "$IMPLEMENTED_COUNT" -gt 0 ]
then
    SCORE=$((PASS_COUNT * 100 / IMPLEMENTED_COUNT))
else
    SCORE=0
fi

printf "%-20s %s%%\n" "Score" "$SCORE"

echo
echo "================================================="
echo

