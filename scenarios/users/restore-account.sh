#!/bin/bash

set -e

scenario_users_restore_account()
{
    #
    # Ensure an alternate primary group exists.
    #
    getent group users >/dev/null ||
        groupadd users

    #
    # Lock the account.
    #
    passwd -l carol >/dev/null

    #
    # Break multiple account attributes.
    #
    usermod \
        -u 5002 \
        -g users \
        -G wheel \
        -s /sbin/nologin \
        carol

    #
    # Expire the account.
    #
    chage \
        -E 2024-01-01 \
        carol
}
