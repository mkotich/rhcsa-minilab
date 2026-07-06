#!/bin/bash

set -e

scenario_nfs_missing_fstab() {
    sed -i '\|[[:space:]]/mnt/share[[:space:]]|d' /etc/fstab

    umount /mnt/share 2> /dev/null || true
}
