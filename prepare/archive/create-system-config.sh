#!/bin/bash

set -e

tar -czf \
    /root/system-config.tar.gz \
    /etc/passwd \
    /etc/group \
    /etc/hosts \
    > /dev/null 2>&1
