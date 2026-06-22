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

SELECTED=$(
    jq -c '.[]' objectives/*.json |
    shuf |
    head -n "$OBJECTIVES" |
    jq -s '.'
)

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

while IFS= read -r OBJECTIVE
do
    echo "$COUNT. $OBJECTIVE"
    COUNT=$((COUNT+1))
done < <(
    echo "$SELECTED" | jq -r '.[].text'
)

echo
echo "================================================="
} > /home/student/EXAM.txt

echo "$SELECTED" > /home/student/exam-state.json

chown student:student \
    /home/student/EXAM.txt \
    /home/student/exam-state.json

chmod 600 \
    /home/student/EXAM.txt \
    /home/student/exam-state.json

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

