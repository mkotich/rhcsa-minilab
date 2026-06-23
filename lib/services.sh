grade_services()
{
    RESULT="PASS"

    EXPECTED_PACKAGE=$(echo "$OBJECT" | jq -r '.answer.package // empty')
    EXPECTED_SERVICE=$(echo "$OBJECT" | jq -r '.answer.service // empty')

    if [ -n "$EXPECTED_PACKAGE" ]
    then
        rpm -q "$EXPECTED_PACKAGE" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SERVICE" ]
    then
        systemctl is-enabled "$EXPECTED_SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SERVICE" ]
    then
        systemctl is-active "$EXPECTED_SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
    fi
}
