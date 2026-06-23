grade_scripts()
{
    RESULT="PASS"

    SCRIPT=$(echo "$OBJECT" | jq -r '.answer.script')
    CONTAINS=$(echo "$OBJECT" | jq -r '.answer.contains')

    [ -f "$SCRIPT" ] || RESULT="FAIL"

    if [ "$RESULT" = "PASS" ]
    then
        [ -x "$SCRIPT" ] || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ]
    then
        grep -q "$CONTAINS" "$SCRIPT" || RESULT="FAIL"
    fi
}
