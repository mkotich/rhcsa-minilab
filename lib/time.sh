grade_time()
{
    RESULT="PASS"

    TIMEZONE=$(echo "$OBJECT" | jq -r '.answer.timezone // empty')
    SERVICE=$(echo "$OBJECT" | jq -r '.answer.service // empty')
    SERVER=$(echo "$OBJECT" | jq -r '.answer.server // empty')

    if [ -n "$TIMEZONE" ]
    then
        timedatectl show --property=Timezone --value |
            grep -qx "$TIMEZONE" || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$SERVICE" ]
    then
        systemctl is-enabled "$SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
        systemctl is-active "$SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    #
    # Chrony server
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$SERVER" ]
    then
        grep -Eq "^server[[:space:]]+${SERVER}([[:space:]]|$)" \
            /etc/chrony.conf || RESULT="FAIL"
    fi
    }
