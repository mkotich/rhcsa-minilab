#!/bin/bash

STATE=/home/student/exam-state.json

show_help() {
    cat <<EOF

Usage:
    peek-exam.sh
        Display the current exam.

    peek-exam.sh <objective-number>
        Display the selected objective and its hint.

    peek-exam.sh <objective-number> --answer
        Display the objective and its answer.

    peek-exam.sh <objective-number> --json
        Display the objective and its JSON definition.

    peek-exam.sh --hint
        Display a random objective and its hint.

    peek-exam.sh --hint <objective-number>
        Display the specified objective and its hint.

    peek-exam.sh --json
        Display the complete exam-state.json.

EOF
}

if [ ! -f "$STATE" ]; then
    echo
    echo "No exam is currently loaded."
    echo
    exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

show_objective() {
    local INDEX="$1"

    echo
    echo "Objective $((INDEX + 1))"
    echo "================"
    echo

    echo "Text"
    echo "----"
    jq -r ".[$INDEX].text" "$STATE"

    echo
    echo "Hint"
    echo "----"
    jq -r ".[$INDEX].hint" "$STATE"

    if [ "$SHOW_JSON" = "1" ]; then
        echo
        echo "JSON"
        echo "----"
        jq ".[$INDEX]" "$STATE"
    fi

    if [ "$SHOW_ANSWER" = "1" ]; then
        echo
        echo "Answer"
        echo "------"
        jq ".[$INDEX].answer" "$STATE"
    fi

    echo
}

#
# Dump entire JSON.
#
if [ "$1" = "--json" ]; then
    jq . "$STATE"
    exit 0
fi

#
# Display exam.
#
if [ $# -eq 0 ]; then
    echo
    echo "Current Exam"
    echo "============"
    echo

    COUNT=1

    while IFS= read -r TEXT
    do
        printf "%2d. %s\n" "$COUNT" "$TEXT"
        COUNT=$((COUNT + 1))
    done < <(
        jq -r '.[].text' "$STATE"
    )

    echo
    echo "Tip:"
    echo "    Run './peek-exam.sh <objective-number>' to view the"
    echo "    objective and its hint."
    echo
    echo "    Examples:"
    echo "        ./peek-exam.sh 8"
    echo "        ./peek-exam.sh 8 --answer"
    echo "        ./peek-exam.sh --hint"
    echo
    exit 0

fi

SHOW_JSON=0
SHOW_ANSWER=0

case "$*" in
    *"--json"*)
        SHOW_JSON=1
        ;;
esac

case "$*" in
    *"--answer"*)
        SHOW_ANSWER=1
        ;;
esac

#
# Random hint.
#
if [ "$1" = "--hint" ]; then

    if [ -n "$2" ] && [[ "$2" =~ ^[0-9]+$ ]]; then
        INDEX=$(( $2 - 1 ))
    else
        COUNT=$(jq 'length' "$STATE")
        INDEX=$(( RANDOM % COUNT ))
    fi

    show_objective "$INDEX"
    exit 0
fi

#
# Numeric lookup.
#
if [[ "$1" =~ ^[0-9]+$ ]]; then
    INDEX=$(( $1 - 1 ))
    show_objective "$INDEX"
    exit 0
fi

echo
echo "Usage:"
echo "    $0"
echo "    $0 <objective>"
echo "    $0 <objective> --answer"
echo "    $0 <objective> --json"
echo "    $0 --hint"
echo "    $0 --hint <objective>"
echo "    $0 --json"
echo

exit 1
