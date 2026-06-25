#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/variables.conf"

MODE="$1"

case "$MODE" in
    mini)
        OBJECTIVES=5
        TIME_LIMIT="15 minutes"
        CATEGORY_LIMIT=1

        CRITICAL_CATEGORIES=(
            networking
            firewall
            selinux
        )

        CORE_COUNT=2
        COMMON_COUNT=0
        OPTIONAL_COUNT=0
        ;;
    small)
        OBJECTIVES=15
        TIME_LIMIT="90 minutes"
        CATEGORY_LIMIT=2

        CRITICAL_CATEGORIES=(
            networking
            firewall
            selinux
        )

        CORE_COUNT=4
        COMMON_COUNT=8
        OPTIONAL_COUNT=0
        ;;
    full)
        OBJECTIVES=25
        TIME_LIMIT="180 minutes"
        CATEGORY_LIMIT=3

        CRITICAL_CATEGORIES=(
            networking
            firewall
            selinux
        )

        CORE_COUNT=6
        COMMON_COUNT=12
        OPTIONAL_COUNT=4
        ;;
    nightmare)
        OBJECTIVES=40
        TIME_LIMIT="Unlimited"
        CATEGORY_LIMIT=999

        CRITICAL_CATEGORIES=(
            networking
            firewall
            selinux
        )

        CORE_COUNT=8
        COMMON_COUNT=20
        OPTIONAL_COUNT=9
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

ALL_OBJECTIVES=$(jq -cs 'add' objectives/*.json)
#
# Filter objectives based on lab mode
#
if [ "$LAB_MODE" = "standalone" ]
then
    ALL_OBJECTIVES=$(
        echo "$ALL_OBJECTIVES" |
        jq '
            map(
                select(
                    (.requires // [])
                    | index("server")
                    | not
                )
            )
        '
    )
fi

declare -A USED_RESOURCE_GROUPS
declare -A CATEGORY_COUNT

add_objective()
{
    OBJECT="$1"

    CURRENT=$(wc -l < "$SELECTED")

    if [ "$CURRENT" -ge "$OBJECTIVES" ]
    then
        return
    fi

    CATEGORY=$(echo "$OBJECT" | jq -r '.category')
    RESOURCE_GROUP=$(echo "$OBJECT" | jq -r '.resource_group // "none"')

    #
    # Category limit
    #
    if [ "${CATEGORY_COUNT[$CATEGORY]:-0}" -ge "$CATEGORY_LIMIT" ]
    then
        return
    fi

    #
    # Resource group already used?
    #
    if [ "$RESOURCE_GROUP" != "none" ]
    then
        if [ -n "${USED_RESOURCE_GROUPS[$RESOURCE_GROUP]}" ]
        then
            return
        fi
    fi

    echo "$OBJECT" >> "$SELECTED"

    CATEGORY_COUNT[$CATEGORY]=$(( ${CATEGORY_COUNT[$CATEGORY]:-0} + 1 ))

    if [ "$RESOURCE_GROUP" != "none" ]
    then
        USED_RESOURCE_GROUPS[$RESOURCE_GROUP]=1
    fi
}

select_category()
{
    CATEGORY="$1"

    echo "$ALL_OBJECTIVES" |
    jq -c --arg category "$CATEGORY" '
        .[]
        | select(.category == $category)
    ' |
    shuf |
    while read OBJECT
    do
        BEFORE=$(wc -l < "$SELECTED")

        add_objective "$OBJECT"

        AFTER=$(wc -l < "$SELECTED")

        [ "$AFTER" -gt "$BEFORE" ] && break
    done
}

select_importance()
{
    IMPORTANCE="$1"
    TARGET="$2"
    ADDED=0

    while read OBJECT
    do
        BEFORE=$(wc -l < "$SELECTED")

        add_objective "$OBJECT"

        AFTER=$(wc -l < "$SELECTED")

        if [ "$AFTER" -gt "$BEFORE" ]
        then
            ADDED=$((ADDED+1))
        fi

        [ "$ADDED" -ge "$TARGET" ] && break

    done < <(
        echo "$ALL_OBJECTIVES" |
        jq -c --arg importance "$IMPORTANCE" '
            .[]
            | select(.importance == $importance)
        ' |
        shuf
    )
}

fill_remaining()
{
    echo "$ALL_OBJECTIVES" |
    jq -c '.[]' |
    shuf |
    while read OBJECT
    do
        add_objective "$OBJECT"

        CURRENT=$(wc -l < "$SELECTED")

        [ "$CURRENT" -ge "$OBJECTIVES" ] && break
    done
}

#
# Mandatory categories
#
for CATEGORY in "${CRITICAL_CATEGORIES[@]}"
do
    select_category "$CATEGORY"
done

#
# Remaining objectives
#
select_importance core "$CORE_COUNT"
select_importance common "$COMMON_COUNT"
select_importance optional "$OPTIONAL_COUNT"

#
# Fill remaining slots
#
fill_remaining


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

