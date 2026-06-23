#!/bin/bash

MODE="$1"

case "$MODE" in
    mini)
        OBJECTIVES=5
        TIME_LIMIT="15 minutes"
        CATEGORY_LIMIT=1
        ;;
    small)
        OBJECTIVES=15
        TIME_LIMIT="90 minutes"
        CATEGORY_LIMIT=2
        ;;
    full)
        OBJECTIVES=25
        TIME_LIMIT="180 minutes"
        CATEGORY_LIMIT=3
        ;;
    nightmare)
        OBJECTIVES=40
        TIME_LIMIT="Unlimited"
        CATEGORY_LIMIT=999
        ;;
    *)
        echo
        echo "Usage:"
        echo "    $0 mini|small|full|nightmare"
        echo
        exit 1
        ;;
esac

SELECTED=$(mktemp)

declare -A USED_RESOURCE_GROUPS
declare -A CATEGORY_COUNT

while read OBJECT
do
    CATEGORY=$(echo "$OBJECT" | jq -r '.category')
    RESOURCE_GROUP=$(echo "$OBJECT" | jq -r '.resource_group // "none"')

    #
    # Skip if resource group already used
    #
    if [ "$RESOURCE_GROUP" != "none" ]
    then
        if [ -n "${USED_RESOURCE_GROUPS[$RESOURCE_GROUP]}" ]
        then
            continue
        fi
    fi

    #
    # Skip if category limit reached
    #
    if [ "${CATEGORY_COUNT[$CATEGORY]:-0}" -ge "$CATEGORY_LIMIT" ]
    then
        continue
    fi

    #
    # Accept objective
    #
    echo "$OBJECT" >> "$SELECTED"

    CATEGORY_COUNT[$CATEGORY]=$(( ${CATEGORY_COUNT[$CATEGORY]:-0} + 1 ))

    if [ "$RESOURCE_GROUP" != "none" ]
    then
        USED_RESOURCE_GROUPS[$RESOURCE_GROUP]=1
    fi

    CURRENT=$(wc -l < "$SELECTED")

    if [ "$CURRENT" -ge "$OBJECTIVES" ]
    then
        break
    fi

done < <(
    jq -c '.[]' objectives/*.json | shuf
)

jq -s '.' "$SELECTED" > /home/student/exam-state.json

{
echo "================================================="
echo "RHCSA MiniLab"
echo "================================================="
echo
echo "Mode:          $MODE"
echo "Objectives:    $OBJECTIVES"
echo "Time Limit:    $TIME_LIMIT"
echo

COUNT=1

while IFS= read -r TEXT
do
    echo "$COUNT. $TEXT"
    COUNT=$((COUNT+1))
done < <(
    jq -r '.[].text' /home/student/exam-state.json
)

echo
echo "================================================="
} > /home/student/EXAM.txt

date +%s > /home/student/exam-start.time

chown student:student \
    /home/student/EXAM.txt \
    /home/student/exam-state.json \
    /home/student/exam-start.time

chmod 600 \
    /home/student/EXAM.txt \
    /home/student/exam-state.json \
    /home/student/exam-start.time

rm -f "$SELECTED"

echo
echo "================================================="
echo "RHCSA MiniLab"
echo "================================================="
echo
echo "Mode:          $MODE"
echo "Objectives:    $OBJECTIVES"
echo "Time Limit:    $TIME_LIMIT"
echo
echo "Exam file:"
echo "    /home/student/EXAM.txt"
echo
echo "Please log in as student to begin."
echo
echo "Good luck."
echo "================================================="
echo

