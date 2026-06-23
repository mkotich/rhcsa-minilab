grade_networking()
{
    RESULT="PASS"

    HOSTNAME=$(echo "$OBJECT" | jq -r '.answer.hostname // empty')
    ADDRESS=$(echo "$OBJECT" | jq -r '.answer.address // empty')

    if [ -n "$HOSTNAME" ]
    then
        [ "$(hostnamectl --static)" = "$HOSTNAME" ] || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$ADDRESS" ]
    then
        ip addr | grep -qw "$ADDRESS" || RESULT="FAIL"
    fi
}
