#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export RHCSA_MINILAB_ROOT="$SCRIPT_DIR"

source "${SCRIPT_DIR}/variables.conf"

MODE="$1"

DEBUG_OBJECTIVE="${DEBUG_OBJECTIVE:-}"

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

ALL_OBJECTIVES=$(jq -cs 'add' "${SCRIPT_DIR}"/objectives/*.json)
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

    #
    # Category limit
    #
    if [ "${CATEGORY_COUNT[$CATEGORY]:-0}" -ge "$CATEGORY_LIMIT" ]
    then
        return
    fi

    echo "$OBJECT" >> "$SELECTED"

    CATEGORY_COUNT[$CATEGORY]=$(( ${CATEGORY_COUNT[$CATEGORY]:-0} + 1 ))
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

random_storage_growth_size()
{
    local SIZES=(
        128M
        256M
        384M

        128MiB
        256MiB
        384MiB

        1G
        2G
        3G

        1GiB
        2GiB
        3GiB
    )

    printf '%s\n' "${SIZES[$(( RANDOM % ${#SIZES[@]} ))]}"
}

display_resource_groups()
{
    [ -z "$RESOURCE_GROUPS" ] && return

    echo
    echo "Required Resource Groups"
    echo "------------------------"

    while read GROUP
    do
        [ -z "$GROUP" ] && continue

        printf "  - %s\n" "$GROUP"

    done <<< "$RESOURCE_GROUPS"
}

prepare_resources()
{
    [ -z "$RESOURCE_GROUPS" ] && return

    echo "Preparing resources..."
    echo

    while read GROUP
    do
        [ -z "$GROUP" ] && continue

        MODULE="${SCRIPT_DIR}/prepare/${GROUP}.sh"

        if [ ! -f "$MODULE" ]
        then
            echo "ERROR: Missing preparation module: $GROUP"
            exit 1
        fi

	source "${SCRIPT_DIR}/lib/prepare.sh"
        source "$MODULE"

        FUNCTION="prepare_${GROUP}"

        if ! declare -F "$FUNCTION" >/dev/null
        then
            echo "ERROR: Missing function ${FUNCTION}()"
            exit 1
        fi

        echo "  Preparing $GROUP..."

        "$FUNCTION"

    done <<< "$RESOURCE_GROUPS"
}

apply_scenarios()
{
    echo
    echo "Applying scenarios..."
    echo

    while IFS=: read -r GROUP SCENARIO
    do
        echo "  ${GROUP}/${SCENARIO}"

        MODULE="${SCRIPT_DIR}/scenarios/${GROUP}/${SCENARIO}.sh"
        FUNCTION="scenario_${GROUP}_${SCENARIO//-/_}"

if [ ! -f "$MODULE" ]
then
    echo
    echo "ERROR: Scenario module not found:"
    echo "    $MODULE"
    exit 1
fi

source "$MODULE"

if ! declare -F "$FUNCTION" >/dev/null
    then
        echo
        echo "ERROR: Scenario function not found:"
        echo "    $FUNCTION"
        exit 1
    fi

    "$FUNCTION"

    done < <(

        jq -r '
            .[]
            | select(has("scenario"))
            | "\(.resource_group):\(.scenario)"
        ' /home/student/exam-state.json |
        sort -u

    )
}

#
# Select exam objectives.
#

if [ -n "$DEBUG_OBJECTIVE" ]
then
    echo "$ALL_OBJECTIVES" |
    jq -c --arg id "$DEBUG_OBJECTIVE" '
        .[]
        | select(.id == $id)
    ' |
    while read OBJECT
    do
        add_objective "$OBJECT"
        break
    done

else

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

fi

jq -s '.' "$SELECTED" > /home/student/exam-state.json

#
# Parameterize objectives.
#

if jq -e '.[] | select(.id=="storage-004")' \
    /home/student/exam-state.json >/dev/null
then
    SIZE=$(random_storage_growth_size)

    jq \
        --arg size "$SIZE" '
        map(
            if .id=="storage-004"
            then
                .text |= (split("${SIZE}") | join($size))
                | .answer.grow_by = $size
            else
                .
            end
        )
        ' \
        /home/student/exam-state.json \
        > /tmp/exam-state.$$

    mv \
        /tmp/exam-state.$$ \
        /home/student/exam-state.json
fi

RESOURCE_GROUPS=$(
    jq -r '.[].resource_group' /home/student/exam-state.json |
    grep -v '^none$' |
    sort -u
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
display_resource_groups
echo
prepare_resources
echo
apply_scenarios
echo
echo "Exam file:"
echo "    /home/student/EXAM.txt"
echo
echo "Please log in as student to begin."
echo
echo "Good luck."
echo "================================================="
echo

