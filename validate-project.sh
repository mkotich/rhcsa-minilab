#!/bin/bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PASS=0
FAIL=0

pass() {
    printf "[PASS] %s\n" "$1"
    PASS=$((PASS + 1))
}

fail() {
    printf "[FAIL] %s\n" "$1"
    FAIL=$((FAIL + 1))
}

echo
echo "================================================="
echo "RHCSA MiniLab Project Validation"
echo "================================================="
echo

OBJECTS=$(jq -sc 'add' "$SCRIPT_DIR"/objectives/*.json)

########################################
# Objective JSON
########################################

JSON_OK=1

for FILE in "$SCRIPT_DIR"/objectives/*.json
do
    if ! jq empty "$FILE" >/dev/null 2>&1
    then
        fail "Invalid JSON: $(basename "$FILE")"
        JSON_OK=0
    fi
done

[ "$JSON_OK" -eq 1 ] && pass "Objective JSON syntax"

if jq -s 'add' "$SCRIPT_DIR"/objectives/*.json >/dev/null 2>&1
then
    pass "Combined objective database"
else
    fail "Combined objective database"
fi

########################################
# Duplicate IDs
########################################

DUPES=$(
    jq -r '.[].id' <<<"$OBJECTS" |
    sort |
    uniq -d
)

if [ -z "$DUPES" ]
then
    pass "Duplicate objective IDs"
else
    fail "Duplicate objective IDs"
    echo "$DUPES"
fi

########################################
# Preparation modules
########################################

while read -r GROUP
do
    [ "$GROUP" = "none" ] && continue

    MODULE="$SCRIPT_DIR/prepare/${GROUP}.sh"

    if [ ! -f "$MODULE" ]
    then
        fail "prepare/${GROUP}.sh (referenced by resource_group=$GROUP)"
        continue
    fi

    if grep -q "^prepare_${GROUP}()" "$MODULE"
    then
        pass "prepare_${GROUP}()"
    else
        fail "prepare_${GROUP}() missing in prepare/${GROUP}.sh"
    fi

done < <(
    jq -r '.[].resource_group' <<<"$OBJECTS" |
    sort -u
)

########################################
# Graders
########################################

while read -r CATEGORY
do
    COUNT=$(jq -r --arg c "$CATEGORY" \
        '[ .[] | select(.category==$c) ] | length' <<<"$OBJECTS")

    if grep -R -q "^grade_${CATEGORY}()" "$SCRIPT_DIR/lib"
    then
        pass "grade_${CATEGORY}()"
    else
        fail "grade_${CATEGORY}() (referenced by $COUNT objective(s))"
    fi

done < <(
    jq -r '.[].category' <<<"$OBJECTS" |
    sort -u
)

########################################
# Scenario modules
########################################

while IFS=: read -r GROUP SCENARIO
do
    [ "$GROUP" = "none" ] && continue

    MODULE="$SCRIPT_DIR/scenarios/${GROUP}/${SCENARIO}.sh"

    ID=$(jq -r \
        --arg g "$GROUP" \
        --arg s "$SCENARIO" \
        '.[]
        | select(.resource_group==$g and .scenario==$s)
        | .id' <<<"$OBJECTS" | head -1)

    if [ -f "$MODULE" ]
    then
        pass "${GROUP}/${SCENARIO}"
    else
        fail "${GROUP}/${SCENARIO} (referenced by ${ID})"
    fi

done < <(
    jq -r '
        .[]
        | select(has("scenario"))
        | "\(.resource_group):\(.scenario)"
    ' <<<"$OBJECTS" |
    sort -u
)

########################################

echo
echo "================================================="
echo "Objectives      : $(jq 'length' <<<"$OBJECTS")"
echo "Categories      : $(jq -r '.[].category' <<<"$OBJECTS" | sort -u | wc -l)"
echo "Resource Groups : $(jq -r '.[].resource_group' <<<"$OBJECTS" | sort -u | wc -l)"
echo "Scenarios       : $(jq -r '.[] | select(has("scenario"))' <<<"$OBJECTS" | wc -l)"
echo
echo "Passed          : $PASS"
echo "Failed          : $FAIL"
echo "================================================="

[ "$FAIL" -eq 0 ]
