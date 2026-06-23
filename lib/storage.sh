grade_storage()
{
    RESULT="PASS"

    EXPECTED_VG=$(echo "$OBJECT" | jq -r '.answer.volume_group // empty')
    EXPECTED_LV=$(echo "$OBJECT" | jq -r '.answer.logical_volume // empty')
    EXPECTED_MOUNT=$(echo "$OBJECT" | jq -r '.answer.mountpoint // empty')
    EXPECTED_FS=$(echo "$OBJECT" | jq -r '.answer.filesystem // empty')
    EXPECTED_PARTITION=$(echo "$OBJECT" | jq -r '.answer.partition // empty')

    if [ -n "$EXPECTED_VG" ]
    then
        vgs "$EXPECTED_VG" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_LV" ]
    then
        lvs "$EXPECTED_VG/$EXPECTED_LV" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_PARTITION" ]
    then
        lsblk "$EXPECTED_PARTITION" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_MOUNT" ]
    then
        findmnt "$EXPECTED_MOUNT" >/dev/null 2>&1 || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ "$EXPECTED_FS" = "swap" ]
    then
        swapon --show | grep -q "$EXPECTED_LV" || RESULT="FAIL"
    fi
}
