grade_selinux() {
    RESULT="PASS"

    EXPECTED_MODE=$(jq -r '.answer.mode // empty' <<< "$OBJECT")
    EXPECTED_BOOLEAN=$(jq -r '.answer.boolean // empty' <<< "$OBJECT")
    EXPECTED_STATE=$(jq -r '.answer.state // empty' <<< "$OBJECT")
    EXPECTED_PATH=$(jq -r '.answer.path // empty' <<< "$OBJECT")
    EXPECTED_CONTEXT=$(jq -r '.answer.context // empty' <<< "$OBJECT")
    EXPECTED_PORT=$(jq -r '.answer.port // empty' <<< "$OBJECT")
    EXPECTED_TYPE=$(jq -r '.answer.type // empty' <<< "$OBJECT")

    #
    # SELinux mode
    #
    if [ -n "$EXPECTED_MODE" ]; then
        [ "$(getenforce)" = "$EXPECTED_MODE" ] ||
            RESULT="FAIL"
    fi

    #
    # SELinux boolean
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_BOOLEAN" ]; then
        getsebool "$EXPECTED_BOOLEAN" | grep -qw "$EXPECTED_STATE" ||
            RESULT="FAIL"
    fi

    #
    # SELinux file context
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_CONTEXT" ]; then
        ls -Zd "$EXPECTED_PATH" 2> /dev/null | grep -qw "$EXPECTED_CONTEXT" ||
            RESULT="FAIL"
    fi

    #
    # SELinux port
    #
    if [ "$RESULT" = "PASS" ] && [ -n "$EXPECTED_PORT" ]; then
        semanage port -l |
            awk -v type="$EXPECTED_TYPE" -v port="$EXPECTED_PORT" '
            $1 == type {
                for (i = 3; i <= NF; i++) {
                    gsub(",", "", $i)

                    if ($i ~ /-/) {
                        split($i, r, "-")
                        if (port >= r[1] && port <= r[2])
                            found=1
                    }
                    else if ($i == port) {
                        found=1
                    }
                }
            }

            END {
                exit !found
            }
        ' || RESULT="FAIL"
    fi
}
