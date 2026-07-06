#!/bin/bash

set -e

tar -cJf \
    /root/system-files.tar.xz \
    /etc/fstab \
    /etc/passwd \
    /etc/group \
    > /dev/null 2>&1
