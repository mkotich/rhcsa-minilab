grade_systemd()
{
    RESULT="PASS"

    TARGET=$(echo "$OBJECT" | jq -r '.answer.target // empty')
    MASKED=$(echo "$OBJECT" | jq -r '.answer.masked // empty')

    if [ -n "$TARGET" ]
    then
        [ "$(systemctl get-default)" = "$TARGET" ] || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$MASKED" ]
    then
        systemctl is-enabled "$MASKED" 2>/dev/null | grep -q masked \
            || RESULT="FAIL"
    fi
}
