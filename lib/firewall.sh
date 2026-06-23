grade_firewall()
{
    RESULT="PASS"

    EXPECTED_SERVICE=$(echo "$OBJECT" | jq -r '.answer.service // empty')

    if [ -n "$EXPECTED_SERVICE" ]
    then
        firewall-cmd --list-services | grep -qw "$EXPECTED_SERVICE" \
            || RESULT="FAIL"
    fi
}
