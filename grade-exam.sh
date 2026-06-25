#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/variables.conf"

STATE=/home/student/exam-state.json

#
# Load all graders
#
for LIB in lib/*.sh
do
    source "$LIB"
done

PASS_COUNT=0
IMPLEMENTED_COUNT=0
TOTAL_COUNT=0

echo
echo "================================================="
echo "RHCSA MiniLab Results"
echo "================================================="
echo

PERSISTENCE="UNKNOWN"

if [ -f /home/student/exam-start.time ]
then
    EXAM_START=$(cat /home/student/exam-start.time)

    BOOT_TIME=$(date -d "$(uptime -s)" +%s)

    if [ "$BOOT_TIME" -gt "$EXAM_START" ]
    then
        PERSISTENCE="VERIFIED"
    else
        PERSISTENCE="NOT VERIFIED"
    fi
fi

printf "%-20s %s\n" "Persistence Check" "$PERSISTENCE"

if [ "$PERSISTENCE" = "NOT VERIFIED" ]
then
    echo
    echo "No reboot has been detected since the exam was launched."
    echo "For best results, reboot and grade again to verify"
    echo "storage, services, networking, firewall, and SELinux persistence."
fi

echo
echo "================================================="
echo

while IFS= read -r OBJECT
do
    CATEGORY=$(echo "$OBJECT" | jq -r '.category')
    TEXT=$(echo "$OBJECT" | jq -r '.text')

    RESULT="NOT IMPLEMENTED"

    FUNCTION="grade_${CATEGORY}"

    if declare -F "$FUNCTION" >/dev/null
    then
        RESULT="PASS"
        "$FUNCTION"
    fi

    printf "[%s] %s\n" "$RESULT" "$TEXT"

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
