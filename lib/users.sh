grade_users()
{
    RESULT="PASS"

    EXPECTED_GROUP_NAME=$(echo "$OBJECT" | jq -r '.answer.group_name // empty')
    EXPECTED_GID=$(echo "$OBJECT" | jq -r '.answer.gid // empty')
    EXPECTED_USERNAME=$(echo "$OBJECT" | jq -r '.answer.username // empty')
    EXPECTED_UID=$(echo "$OBJECT" | jq -r '.answer.uid // empty')
    EXPECTED_SHELL=$(echo "$OBJECT" | jq -r '.answer.shell // empty')
    EXPECTED_SUPP_GROUP=$(echo "$OBJECT" | jq -r '.answer.supplementary_group // empty')

    if [ -n "$EXPECTED_GROUP_NAME" ]
    then
        GROUP_ENTRY=$(getent group "$EXPECTED_GROUP_NAME") || RESULT="FAIL"

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_GID" ]
        then
            ACTUAL_GID=$(echo "$GROUP_ENTRY" | cut -d: -f3)
            [ "$ACTUAL_GID" = "$EXPECTED_GID" ] || RESULT="FAIL"
        fi
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_USERNAME" ]
    then
        id "$EXPECTED_USERNAME" >/dev/null 2>&1 || RESULT="FAIL"

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_UID" ]
        then
            ACTUAL_UID=$(id -u "$EXPECTED_USERNAME")
            [ "$ACTUAL_UID" = "$EXPECTED_UID" ] || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SHELL" ]
        then
            ACTUAL_SHELL=$(getent passwd "$EXPECTED_USERNAME" | cut -d: -f7)
            [ "$ACTUAL_SHELL" = "$EXPECTED_SHELL" ] || RESULT="FAIL"
        fi

        if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SUPP_GROUP" ]
        then
            id -nG "$EXPECTED_USERNAME" | grep -qw "$EXPECTED_SUPP_GROUP" || RESULT="FAIL"
        fi
    fi
}
