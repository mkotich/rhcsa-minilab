#!/bin/bash

grade_links() {
    RESULT="PASS"

    TYPE=$(jq -r '.answer.type' <<< "$OBJECT")
    TARGET=$(jq -r '.answer.target' <<< "$OBJECT")
    LINK=$(jq -r '.answer.link' <<< "$OBJECT")

    #
    # Link must exist.
    #
    [ -e "$LINK" ] || {
        RESULT="FAIL"
        return
    }

    case "$TYPE" in
        symbolic)
            [ -L "$LINK" ] || {
                RESULT="FAIL"
                return
            }

            [ "$(readlink "$LINK")" = "$TARGET" ] || {
                RESULT="FAIL"
                return
            }
            ;;

        hard)
            [ ! -L "$LINK" ] || {
                RESULT="FAIL"
                return
            }

            [ "$(stat -c %i "$TARGET")" = \
                "$(stat -c %i "$LINK")" ] || {
                RESULT="FAIL"
                return
            }
            ;;

        *)
            RESULT="FAIL"
            ;;
    esac
}
