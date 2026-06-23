grade_timers()
{
    RESULT="PASS"

    TIMER=$(echo "$OBJECT" | jq -r '.answer.timer')

    systemctl is-enabled "$TIMER" >/dev/null 2>&1 || RESULT="FAIL"

    if [ "$RESULT" = "PASS" ]
    then
        systemctl is-active "$TIMER" >/dev/null 2>&1 || RESULT="FAIL"
    fi
}
