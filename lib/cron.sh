grade_cron() {
    RESULT="PASS"

    EXPECTED_SCHEDULE=$(echo "$OBJECT" | jq -r '.answer.schedule')
    EXPECTED_COMMAND=$(echo "$OBJECT" | jq -r '.answer.command')

    crontab -l 2> /dev/null |
        grep -F "${EXPECTED_SCHEDULE} ${EXPECTED_COMMAND}" > /dev/null ||
        RESULT="FAIL"
}
