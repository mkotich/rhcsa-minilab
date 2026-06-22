#!/bin/bash

STATE=/home/student/exam-state.json

if [ ! -f "$STATE" ]
then
    echo
    echo "No exam is currently loaded."
    echo
    exit 1
fi

if [ "$1" = "--json" ]
then
    jq . "$STATE"
    exit 0
fi

if [ -z "$1" ]
then
    echo
    echo "Current Exam"
    echo "============"
    echo

    COUNT=1

    while IFS= read -r TEXT
    do
        echo "$COUNT. $TEXT"
        COUNT=$((COUNT+1))
    done < <(
        jq -r '.[].text' "$STATE"
    )

    echo
    exit 0
fi

NUMBER="$1"
INDEX=$((NUMBER-1))

echo
echo "Objective $NUMBER"
echo "================"
echo

echo "Text"
echo "----"
jq -r ".[$INDEX].text" "$STATE"

echo
echo "Hint"
echo "----"
jq -r ".[$INDEX].hint" "$STATE"

if [ "$2" = "--json" ]
then
    echo
    echo "JSON"
    echo "----"
    jq ".[$INDEX]" "$STATE"

elif [ "$2" = "--answer" ]
then
    echo
    echo "Answer"
    echo "------"
    jq ".[$INDEX].answer" "$STATE"
fi

echo

