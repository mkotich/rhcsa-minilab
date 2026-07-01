#!/bin/bash

set -e

prepare_users_repair()
{
    getent group developers >/dev/null ||
        groupadd -g 2000 developers
    getent group admins >/dev/null ||
        groupadd admins

    if ! id carol >/dev/null 2>&1
    then
        useradd \
            -u 2002 \
            -g developers \
            -G wheel,admins \
            -m \
            -s /bin/bash \
            carol
    fi

    usermod \
        -u 2002 \
        -g developers \
        -G wheel \
        -s /bin/bash \
        carol

    echo 'carol:redhat' | chpasswd

    passwd -u carol >/dev/null 2>&1 || true

    chage -E 2028-06-30 carol

    chown -R \
        carol:developers \
        /home/carol
}
