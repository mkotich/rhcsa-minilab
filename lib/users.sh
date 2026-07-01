grade_users()
{
    RESULT="PASS"

    local EXPECTED_USERNAME
    local EXPECTED_GROUP
    local EXPECTED_UID
    local EXPECTED_GID
    local EXPECTED_PRIMARY_GROUP
    local EXPECTED_SHELL
    local EXPECTED_EXPIRE_DATE
    local EXPECTED_LOCKED
    local ACTUAL_GID
    local ACTUAL_SHELL
    local STATUS
    local GROUP

    EXPECTED_USERNAME=$(jq -r '.answer.username // empty' <<<"$OBJECT")
    EXPECTED_GROUP=$(jq -r '.answer.group_name // empty' <<<"$OBJECT")
    EXPECTED_UID=$(jq -r '.answer.uid // empty' <<<"$OBJECT")
    EXPECTED_GID=$(jq -r '.answer.gid // empty' <<<"$OBJECT")
    EXPECTED_PRIMARY_GROUP=$(jq -r '.answer.primary_group // empty' <<<"$OBJECT")
    EXPECTED_SHELL=$(jq -r '.answer.shell // empty' <<<"$OBJECT")
    EXPECTED_EXPIRE_DATE=$(jq -r '.answer.expire_date // empty' <<<"$OBJECT")

    EXPECTED_LOCKED=$(jq -r '
        if .answer | has("locked")
        then .answer.locked
        else empty
        end
    ' <<<"$OBJECT")

    #
    # Group exists.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_GROUP" ]
    then
        getent group "$EXPECTED_GROUP" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    #
    # Group GID.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_GID" ]
    then
        ACTUAL_GID=$(getent group "$EXPECTED_GROUP" | cut -d: -f3)
        [ "$ACTUAL_GID" = "$EXPECTED_GID" ] || RESULT="FAIL"
    fi

    #
    # User exists.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_USERNAME" ]
    then
        id "$EXPECTED_USERNAME" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    #
    # UID.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_UID" ]
    then
        [ "$(id -u "$EXPECTED_USERNAME")" = "$EXPECTED_UID" ] || RESULT="FAIL"
    fi

    #
    # Primary group.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_PRIMARY_GROUP" ]
    then
        [ "$(id -gn "$EXPECTED_USERNAME")" = "$EXPECTED_PRIMARY_GROUP" ] || RESULT="FAIL"
    fi

    #
    # Supplementary groups.
    #
    if [ "$RESULT" = "PASS" ]
    then
        while read -r GROUP
        do
            [ -z "$GROUP" ] && continue

            id -nG "$EXPECTED_USERNAME" |
                tr ' ' '\n' |
                grep -qx "$GROUP" || {
                    RESULT="FAIL"
                    break
                }

        done < <(jq -r '.answer.supplementary_groups[]?' <<<"$OBJECT")
    fi

    #
    # Login shell.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_SHELL" ]
    then
        ACTUAL_SHELL=$(getent passwd "$EXPECTED_USERNAME" | cut -d: -f7)
        [ "$ACTUAL_SHELL" = "$EXPECTED_SHELL" ] || RESULT="FAIL"
    fi

    #
    # Account expiration.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_EXPIRE_DATE" ]
    then
        chage -l "$EXPECTED_USERNAME" |
            grep -q "$EXPECTED_EXPIRE_DATE" || RESULT="FAIL"
    fi

    #
    # Locked / unlocked.
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_LOCKED" ]
    then
        STATUS=$(passwd -S "$EXPECTED_USERNAME" | awk '{print $2}')

        case "$EXPECTED_LOCKED" in
            true)
                [ "$STATUS" = "L" ] || RESULT="FAIL"
                ;;
            false)
                [ "$STATUS" != "L" ] || RESULT="FAIL"
                ;;
        esac
    fi
}
