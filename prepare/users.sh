#!/bin/bash

set -e

source prepare/users/configuration.sh
source prepare/users/repair.sh

prepare_users() {
    #
    # Debug mode: prepare only the requested objective.
    #
    if [ -n "$DEBUG_OBJECTIVE" ]; then
        case "$DEBUG_OBJECTIVE" in

            users-001 | users-002 | users-003 | users-004 | users-005)
                prepare_users_configuration "$DEBUG_OBJECTIVE"
                ;;

            users-006 | users-007 | users-008 | users-009 | users-010 | users-011 | users-012)
                prepare_users_repair
                ;;

        esac

        return
    fi

    #
    # Normal exam mode.
    #
    jq -r '.[].id' /home/student/exam-state.json |
        while read -r ID; do
            case "$ID" in

                users-001 | users-002 | users-003 | users-004 | users-005)
                    prepare_users_configuration "$ID"
                    ;;

                users-006 | users-007 | users-008 | users-009 | users-010 | users-011 | users-012)
                    prepare_users_repair
                    ;;

            esac
        done
}
