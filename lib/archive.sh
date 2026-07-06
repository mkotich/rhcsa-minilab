grade_archive() {
    RESULT="FAIL"

    local ARCHIVE
    ARCHIVE=$(jq -r '.answer.archive' <<< "$OBJECT")

    #
    # Archive must exist for every archive objective.
    #
    [ -f "$ARCHIVE" ] || return

    #
    # Creation objective (exact members)
    #
    if jq -e '.answer.members?' <<< "$OBJECT" > /dev/null; then
        EXPECTED=$(
            jq -r '.answer.members[]' <<< "$OBJECT" | sort
        )

        ACTUAL=$(
            tar tf "$ARCHIVE" 2> /dev/null |
                grep -v '/$' |
                sort
        )

        [ "$EXPECTED" = "$ACTUAL" ] && RESULT="PASS"
        return
    fi

    #
    # Listing objective
    #
    if jq -e '.answer.output?' <<< "$OBJECT" > /dev/null; then
        OUTPUT=$(jq -r '.answer.output' <<< "$OBJECT")

        [ -f "$OUTPUT" ] || return

        EXPECTED=$(
            jq -r '.answer.members[]' <<< "$OBJECT" | sort
        )

        ACTUAL=$(
            sort "$OUTPUT" 2> /dev/null
        )

        [ "$EXPECTED" = "$ACTUAL" ] && RESULT="PASS"
        return
    fi

    #
    # Exclude objective
    #
    if jq -e '.answer.exclude?' <<< "$OBJECT" > /dev/null; then
        EXCLUDE=$(jq -r '.answer.exclude' <<< "$OBJECT")

        if ! tar tf "$ARCHIVE" 2> /dev/null | grep -qx "$EXCLUDE"; then
            RESULT="PASS"
        fi

        return
    fi

    #
    # Single-member extraction
    #
    if jq -e '.answer.member?' <<< "$OBJECT" > /dev/null; then
        DEST=$(jq -r '.answer.destination' <<< "$OBJECT")
        MEMBER=$(jq -r '.answer.member' <<< "$OBJECT")

        [ -f "$DEST/$MEMBER" ] && RESULT="PASS"
        return
    fi

    #
    # Extraction objective
    #
    if jq -e '.answer.destination?' <<< "$OBJECT" > /dev/null; then
        DEST=$(jq -r '.answer.destination' <<< "$OBJECT")

        if tar tf "$ARCHIVE" 2> /dev/null |
            grep -v '/$' |
            while read -r FILE; do
                [ -f "$DEST/$FILE" ] || exit 1
            done; then
            RESULT="PASS"
        fi

        return
    fi

    RESULT="NOT IMPLEMENTED"
}
