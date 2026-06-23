grade_nfs()
{
    RESULT="PASS"

    PACKAGE=$(echo "$OBJECT" | jq -r '.answer.package')

    rpm -q "$PACKAGE" >/dev/null 2>&1 || RESULT="FAIL"
}
