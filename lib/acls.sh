grade_acls() {
    RESULT="PASS"

    PATHNAME=$(jq -r '.answer.path' <<< "$OBJECT")

    USER=$(jq -r '.answer.user // empty' <<< "$OBJECT")
    GROUP=$(jq -r '.answer.group // empty' <<< "$OBJECT")
    DEFAULT_USER=$(jq -r '.answer.default_user // empty' <<< "$OBJECT")

    PERMS=$(jq -r '.answer.permissions // empty' <<< "$OBJECT")
    PRESENT=$(jq -r '.answer.present // "true"' <<< "$OBJECT")

    ACL=$(getfacl "$PATHNAME" 2> /dev/null)

    if [ -n "$USER" ]; then
        ENTRY="user:${USER}:${PERMS}"
    elif [ -n "$GROUP" ]; then
        ENTRY="group:${GROUP}:${PERMS}"
    elif [ -n "$DEFAULT_USER" ]; then
        ENTRY="default:user:${DEFAULT_USER}:${PERMS}"
    else
        RESULT="FAIL"
        return
    fi

    if [ "$PRESENT" = "false" ]; then
        echo "$ACL" | grep -F "$ENTRY" > /dev/null &&
            RESULT="FAIL"
    else
        echo "$ACL" | grep -F "$ENTRY" > /dev/null ||
            RESULT="FAIL"
    fi
}
