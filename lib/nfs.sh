grade_nfs() {
    RESULT="PASS"

    SERVER=$(echo "$OBJECT" | jq -r '.answer.server')
    EXPORT=$(echo "$OBJECT" | jq -r '.answer.export')
    MOUNTPOINT=$(echo "$OBJECT" | jq -r '.answer.mountpoint')

    EXPECTED="${SERVER}:${EXPORT}"

    mount | grep -q "^${EXPECTED} on ${MOUNTPOINT} " ||
        RESULT="FAIL"

    if [ "$RESULT" = "PASS" ]; then
        grep -Eq "[[:space:]]${MOUNTPOINT}[[:space:]]+nfs" /etc/fstab ||
            RESULT="FAIL"
    fi
}
