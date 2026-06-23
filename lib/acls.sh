grade_acls()
{
    RESULT="PASS"

    PATHNAME=$(echo "$OBJECT" | jq -r '.answer.path')
    USERNAME=$(echo "$OBJECT" | jq -r '.answer.user')
    PERMS=$(echo "$OBJECT" | jq -r '.answer.perms')

    getfacl "$PATHNAME" 2>/dev/null |
        grep -F "user:${USERNAME}:${PERMS}" >/dev/null \
        || RESULT="FAIL"
}
