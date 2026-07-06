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
            users-001|users-002|users-003|users-004|users-005)
                prepare_users_configuration "$DEBUG_OBJECTIVE"
                ;;
            users-006|users-007|users-008|users-009|users-010|users-011|users-012)
                prepare_users_repair
                ;;
        esac
        return
    fi

    #
    # Normal exam mode.
    #
    echo "      Scanning user objectives..."

    NEED_CONFIGURATION=0
    NEED_REPAIR=0
    CONFIG_OBJECTIVE=""

    while IFS= read -r ID
    do
        echo "        Objective: $ID"

        case "$ID" in

            users-001|users-002|users-003|users-004|users-005)

                NEED_CONFIGURATION=1

                #
                # Keep the most advanced configuration objective.
                #
                case "$ID" in
                    users-005)
                        CONFIG_OBJECTIVE="users-005"
                        ;;
                    users-004)
                        [ "$CONFIG_OBJECTIVE" != "users-005" ] &&
                            CONFIG_OBJECTIVE="users-004"
                        ;;
                    users-003)
                        [ -z "$CONFIG_OBJECTIVE" ] &&
                            CONFIG_OBJECTIVE="users-003"
                        ;;
                    users-002)
                        [ -z "$CONFIG_OBJECTIVE" ] &&
                            CONFIG_OBJECTIVE="users-002"
                        ;;
                    users-001)
                        [ -z "$CONFIG_OBJECTIVE" ] &&
                            CONFIG_OBJECTIVE="users-001"
                        ;;
                esac
                ;;

            users-006|users-007|users-008|users-009|users-010|users-011|users-012)

                NEED_REPAIR=1
                ;;

        esac

    done < <(
        jq -r '.[].id' /home/student/exam-state.json
    )

    if [ "$NEED_CONFIGURATION" -eq 1 ]; then
        echo "      Running prepare_users_configuration ($CONFIG_OBJECTIVE)"
        prepare_users_configuration "$CONFIG_OBJECTIVE"
    fi

    if [ "$NEED_REPAIR" -eq 1 ]; then
        echo "      Running prepare_users_repair"
        prepare_users_repair
    fi

    echo "      prepare_users complete"
}
