grade_kernel()
{
    RESULT="PASS"

    NAME=$(echo "$OBJECT" | jq -r '.answer.name')
    VALUE=$(echo "$OBJECT" | jq -r '.answer.value')

    sysctl -n "$NAME" 2>/dev/null |
        grep -qx "$VALUE" || RESULT="FAIL"
}
