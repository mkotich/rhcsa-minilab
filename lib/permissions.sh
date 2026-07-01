grade_permissions()
{
    RESULT="PASS"
    EXPECTED_PATH=$(echo "$OBJECT" | jq -r '.answer.path')
    EXPECTED_MODE=$(echo "$OBJECT" | jq -r '.answer.mode')
    ACTUAL_MODE=$(stat -c %a "$EXPECTED_PATH" 2>/dev/null)
    [ "$ACTUAL_MODE" = "$EXPECTED_MODE" ] || RESULT="FAIL"
}
