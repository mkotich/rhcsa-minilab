#!/bin/bash

#
# Scenario:
#     Filesystem missing.
#
# Description:
#     The logical volume exists but contains no filesystem.
#

set -e

source lib/storage.sh

scenario_storage_create_filesystem() {
    create_lvm \
        /dev/sdb \
        vgapps \
        lvapps \
        512M \
        xfs \
        /apps

    #
    # Remove the filesystem.
    #
    umount /apps

    wipefs -af /dev/vgapps/lvapps > /dev/null 2>&1

    #
    # Remove the fstab entry.
    #
    sed -i '\|[[:space:]]/apps[[:space:]]|d' /etc/fstab
}
