#!/bin/bash

set -e

prepare_users_configuration() {
    local OBJECTIVE="$1"

    #
    # Remove repair objects.
    #
    id carol > /dev/null 2>&1 &&
        userdel -rf carol > /dev/null 2>&1 || true

    getent group admins > /dev/null &&
        groupdel admins > /dev/null 2>&1 || true

    #
    # Remove configuration objects.
    #
    id alice > /dev/null 2>&1 &&
        userdel -rf alice > /dev/null 2>&1 || true

    getent group developers > /dev/null &&
        groupdel developers > /dev/null 2>&1 || true

    case "$OBJECTIVE" in

        #
        # Create developers.
        #
        users-001)
            ;;

        #
        # Create alice.
        #
        users-002)

            groupadd -g 2000 developers

            ;;

        #
        # Configure alice.
        #
        users-003 | users-004 | users-005)

            groupadd -g 2000 developers

            useradd \
                -u 2001 \
                -g developers \
                -m \
                alice

            echo 'alice:redhat' | chpasswd

            ;;

    esac
}
