#!/bin/bash

#
# Scenario:
#     Incorrect filesystem UUID in /etc/fstab.
#
# Description:
#     Replace the filesystem UUID with the logical volume UUID.
#

set -e

source lib/storage.sh

scenario_storage_wrong_uuid()
{
    create_lvm \
        /dev/sdb \
        vgapps \
        lvapps \
        512M \
        xfs \
        /apps

    #
    # Replace the filesystem UUID with the LV UUID.
    #
    local FS_UUID
    local LV_UUID

    FS_UUID=$(blkid -s UUID -o value /dev/vgapps/lvapps)
    LV_UUID=$(lvs --noheadings -o lv_uuid vgapps/lvapps | xargs)

sed -i \
    "\|[[:space:]]/apps[[:space:]]|s/${FS_UUID}/${LV_UUID}/" \
    /etc/fstab
}
