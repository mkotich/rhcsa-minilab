grade_ssh()
{
    RESULT="PASS"

    SERVICE=$(echo "$OBJECT" | jq -r '.answer.service // empty')
    ROOTLOGIN=$(echo "$OBJECT" | jq -r '.answer.permitrootlogin // empty')
    PASSAUTH=$(echo "$OBJECT" | jq -r '.answer.passwordauthentication // empty')

    if [ -n "$SERVICE" ]
    then
        systemctl is-enabled "$SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
        systemctl is-active "$SERVICE" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$ROOTLOGIN" ]
    then
        sshd -T | grep -q "^permitrootlogin $ROOTLOGIN$" || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$PASSAUTH" ]
    then
        sshd -T | grep -q "^passwordauthentication $PASSAUTH$" || RESULT="FAIL"
    fi
}
