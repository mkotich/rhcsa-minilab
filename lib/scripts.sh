#!/bin/bash

grade_scripts() {
    RESULT="PASS"

    local SCRIPT
    local TEST_COUNT
    local i

    SCRIPT=$(jq -r '.answer.script' <<< "$OBJECT")

    #
    # Script must exist.
    #
    [ -f "$SCRIPT" ] || {
        RESULT="FAIL"
        return
    }

    #
    # Script must be executable.
    #
    [ -x "$SCRIPT" ] || {
        RESULT="FAIL"
        return
    }

    TEST_COUNT=$(jq '.answer.tests | length' <<< "$OBJECT")

    for ((i = 0; i < TEST_COUNT; i++)); do
        grade_script_test "$SCRIPT" "$i"

        [ "$RESULT" = "PASS" ] || return
    done
}

grade_script_test() {
    local SCRIPT="$1"
    local INDEX="$2"

    local STDOUT_FILE
    local STDERR_FILE
    local ACTUAL_STDOUT
    local ACTUAL_STDERR
    local EXPECTED_STDOUT
    local EXPECTED_STDERR
    local EXPECTED_EXIT
    local RC

    local -a ARGS

    STDOUT_FILE=$(mktemp)
    STDERR_FILE=$(mktemp)

    mapfile -t ARGS < <(
        jq -r ".answer.tests[$INDEX].args[]" <<< "$OBJECT"
    )

    "$SCRIPT" "${ARGS[@]}" \
        > "$STDOUT_FILE" \
        2> "$STDERR_FILE"

    RC=$?

    ACTUAL_STDOUT=$(< "$STDOUT_FILE")
    ACTUAL_STDERR=$(< "$STDERR_FILE")

    STDOUT_COMMAND=$(
        jq -r ".answer.tests[$INDEX].stdout_command // empty" <<< "$OBJECT"
    )

    if [ -n "$STDOUT_COMMAND" ]; then
        EXPECTED_STDOUT=$(eval "$STDOUT_COMMAND")
    else
        EXPECTED_STDOUT=$(
            jq -r ".answer.tests[$INDEX].stdout" <<< "$OBJECT"
        )
    fi

    EXPECTED_STDERR=$(
        jq -r ".answer.tests[$INDEX].stderr" <<< "$OBJECT"
    )

    EXPECTED_EXIT=$(
        jq -r ".answer.tests[$INDEX].exit" <<< "$OBJECT"
    )

    [ "$ACTUAL_STDOUT" = "$EXPECTED_STDOUT" ] ||
        RESULT="FAIL"

    [ "$ACTUAL_STDERR" = "$EXPECTED_STDERR" ] ||
        RESULT="FAIL"

    [ "$RC" = "$EXPECTED_EXIT" ] ||
        RESULT="FAIL"

    rm -f \
        "$STDOUT_FILE" \
        "$STDERR_FILE"
}
