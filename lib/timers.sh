grade_timers() {
    RESULT="PASS"

    TIMER=$(jq -r '.answer.timer // empty' <<< "$OBJECT")
    SERVICE=$(jq -r '.answer.service // empty' <<< "$OBJECT")
    ONCALENDAR=$(jq -r '.answer.oncalendar // empty' <<< "$OBJECT")
    ENABLED=$(jq -r '.answer.enabled // empty' <<< "$OBJECT")
    ACTIVE=$(jq -r '.answer.active // empty' <<< "$OBJECT")

    #
    # Service must exist.
    #
    if [ -n "$SERVICE" ]; then
        systemctl cat "$SERVICE" > /dev/null 2>&1 ||
            RESULT="FAIL"
    fi

    #
    # Timer must exist.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$TIMER" ]; then
        systemctl cat "$TIMER" > /dev/null 2>&1 ||
            RESULT="FAIL"
    fi

    #
    # Verify OnCalendar.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$ONCALENDAR" ]; then
        systemctl cat "$TIMER" |
            grep -q "^OnCalendar=${ONCALENDAR}$" ||
            RESULT="FAIL"
    fi

    #
    # Enabled?
    #
    if [ "$RESULT" = "PASS" ] && [ "$ENABLED" = "true" ]; then
        systemctl is-enabled "$TIMER" > /dev/null 2>&1 ||
            RESULT="FAIL"
    fi

    #
    # Active?
    #
    if [ "$RESULT" = "PASS" ] && [ "$ACTIVE" = "true" ]; then
        systemctl is-active "$TIMER" > /dev/null 2>&1 ||
            RESULT="FAIL"
    fi
}
