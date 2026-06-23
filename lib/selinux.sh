grade_selinux()
{
    RESULT="PASS"

    EXPECTED_MODE=$(echo "$OBJECT" | jq -r '.answer.mode // empty')
    EXPECTED_BOOLEAN=$(echo "$OBJECT" | jq -r '.answer.boolean // empty')
    EXPECTED_VALUE=$(echo "$OBJECT" | jq -r '.answer.value // empty')
    EXPECTED_PATH=$(echo "$OBJECT" | jq -r '.answer.path // empty')
    EXPECTED_CONTEXT=$(echo "$OBJECT" | jq -r '.answer.context // empty')

    if [ -n "$EXPECTED_MODE" ]
    then
        [ "$(getenforce)" = "$EXPECTED_MODE" ] || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_BOOLEAN" ]
    then
        getsebool "$EXPECTED_BOOLEAN" | grep -qw "$EXPECTED_VALUE" \
            || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_PATH" ]
    then
        ls -Zd "$EXPECTED_PATH" 2>/dev/null | grep -qw "$EXPECTED_CONTEXT" \
            || RESULT="FAIL"
    fi
}
