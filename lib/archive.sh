grade_archive()
{
    RESULT="PASS"

    ARCHIVE=$(echo "$OBJECT" | jq -r '.answer.archive')

    [ -f "$ARCHIVE" ] || RESULT="FAIL"

    if [ "$RESULT" = "PASS" ]
    then
        tar tf "$ARCHIVE" >/dev/null 2>&1 || RESULT="FAIL"
    fi
}
