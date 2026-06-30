#!/bin/bash

#
# Scenario:
#     Extend the logical volume.
#
# Description:
#     The storage is configured correctly.
#     The student must extend the LV and filesystem.
#

set -e

source lib/storage.sh

scenario_storage_grow_lv()
{
    create_lvm \
        /dev/sdb \
        vgapps \
        lvapps \
        512M \
        xfs \
        /apps
}
