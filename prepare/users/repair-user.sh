#!/bin/bash

set -e

#
# users-006+
#

if ! getent group developers > /dev/null; then
    groupadd -g 2000 developers
fi

if ! id carol > /dev/null 2>&1; then
    useradd \
        -u 2002 \
        -g developers \
        -G wheel \
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

passwd -u carol > /dev/null 2>&1 || true

chage -E 2028-06-30 carol

chown -R carol:developers /home/carol
