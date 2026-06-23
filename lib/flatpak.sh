grade_flatpak()
{
    RESULT="PASS"

    EXPECTED_PACKAGE=$(echo "$OBJECT" | jq -r '.answer.package // empty')
    EXPECTED_REMOTE=$(echo "$OBJECT" | jq -r '.answer.remote // empty')
    EXPECTED_APPLICATION=$(echo "$OBJECT" | jq -r '.answer.application // empty')

    if [ -n "$EXPECTED_PACKAGE" ]
    then
        rpm -q "$EXPECTED_PACKAGE" >/dev/null 2>&1 \
            || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_REMOTE" ]
    then
        flatpak remotes --columns=name 2>/dev/null |
            grep -qx "$EXPECTED_REMOTE" \
            || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_APPLICATION" ]
    then
        flatpak list --columns=application 2>/dev/null |
            grep -qx "$EXPECTED_APPLICATION" \
            || RESULT="FAIL"
    fi
}
