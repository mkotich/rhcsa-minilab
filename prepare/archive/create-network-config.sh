#!/bin/bash

set -e

tar -cjf \
    /root/network-config.tar.bz2 \
    /etc/hostname \
    /etc/hosts \
    /etc/resolv.conf \
    > /dev/null 2>&1
