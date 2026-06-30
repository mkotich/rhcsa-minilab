#!/bin/bash

#
# Scenario:
#     Missing /etc/fstab entry.
#
# Description:
#     Remove the persistent mount configuration for /apps.
#

set -e

source lib/storage.sh

scenario_storage_missing_fstab()
{
    create_lvm \
        /dev/sdb \
        vgapps \
        lvapps \
        512M \
        xfs \
        /apps

    #
    # Remove the persistent mount entry.
    #
    sed -i '\|[[:space:]]/apps[[:space:]]|d' /etc/fstab

    #
    # Unmount the filesystem.
    #
    umount /apps
}
