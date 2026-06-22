#!/bin/bash

MODE="$1"

case "$MODE" in
    mini)
        OBJECTIVES=5
        TIME_LIMIT="15 minutes"
        ;;
    small)
        OBJECTIVES=15
        TIME_LIMIT="90 minutes"
        ;;
    full)
        OBJECTIVES=25
        TIME_LIMIT="180 minutes"
        ;;
    nightmare)
        OBJECTIVES=40
        TIME_LIMIT="Unlimited"
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

jq -c '.[]' objectives/*.json |
shuf |
while read OBJECT
do
    RESOURCE_GROUP=$(echo "$OBJECT" | jq -r '.resource_group')

    #
    # Skip if resource group already used
    #
    if [ "$RESOURCE_GROUP" != "none" ]
    then
        if [ -n "${USED_RESOURCE_GROUPS[$RESOURCE_GROUP]}" ]
        then
            continue
        fi

        USED_RESOURCE_GROUPS[$RESOURCE_GROUP]=1
    fi

    echo "$OBJECT" >> "$SELECTED"

    CURRENT=$(wc -l < "$SELECTED")

    if [ "$CURRENT" -ge "$OBJECTIVES" ]
    then
        break
    fi

done

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

chown student:student \
    /home/student/EXAM.txt \
    /home/student/exam-state.json

chmod 600 \
    /home/student/EXAM.txt \
    /home/student/exam-state.json

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

