#!/bin/bash

set -e

source lib/storage.sh

prepare_storage() {
    OBJECT_ID=$(jq -r '.[0].id' /home/student/exam-state.json)

    case "$OBJECT_ID" in

        storage-001)

            cleanup_storage \
                vgapps \
                lvapps \
                /apps \
                /dev/sdb

            partprobe /dev/sdb > /dev/null 2>&1 || true
            udevadm settle
            ;;

        *)

            create_lvm \
                /dev/sdb \
                vgapps \
                lvapps \
                512M \
                xfs \
                /apps
            ;;
    esac
}
