grade_systemd()
{
    RESULT="PASS"

    TARGET=$(jq -r '.answer.target // empty' <<<"$OBJECT")
    SERVICE=$(jq -r '.answer.service // empty' <<<"$OBJECT")
    STATE=$(jq -r '.answer.state // empty' <<<"$OBJECT")

    if [ -n "$TARGET" ]
    then
        [ "$(systemctl get-default)" = "$TARGET" ] || RESULT="FAIL"
    fi

    if [ "$RESULT" = "PASS" ] && [ -n "$SERVICE" ]
    then
        CURRENT=$(systemctl is-enabled "$SERVICE" 2>/dev/null)

        case "$STATE" in
            masked)
                [ "$CURRENT" = "masked" ] || RESULT="FAIL"
                ;;
            unmasked)
                [ "$CURRENT" != "masked" ] || RESULT="FAIL"
                ;;
        esac
    fi
}
