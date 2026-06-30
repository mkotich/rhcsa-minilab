#!/bin/bash

set -e

source lib/storage.sh

prepare_storage()
{
    create_lvm \
        /dev/sdb \
        vgapps \
        lvapps \
        512M \
        xfs \
        /apps
}
