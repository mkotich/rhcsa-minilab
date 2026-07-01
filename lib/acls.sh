grade_acls()
{
    RESULT="PASS"

    PATHNAME=$(jq -r '.answer.path' <<<"$OBJECT")
    USERNAME=$(jq -r '.answer.user' <<<"$OBJECT")
    PERMS=$(jq -r '.answer.perms' <<<"$OBJECT")

    getfacl "$PATHNAME" 2>/dev/null |
        grep -F "user:${USERNAME}:${PERMS}" >/dev/null ||
        RESULT="FAIL"
}
