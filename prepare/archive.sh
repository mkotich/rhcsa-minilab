#!/bin/bash

set -e

prepare_archive()
{
    mkdir -p /archive-restore

    find /archive-restore -mindepth 1 -delete

    rm -f \
        /root/system-config.tar.gz \
        /root/network-config.tar.bz2 \
        /root/system-files.tar.xz \
        /root/system-no-ssh.tar.gz \
        /home/student/tar-output.txt

    #
    # Only create archives needed by the selected objectives.
    #

    jq -r '.[].id' /home/student/exam-state.json |
    while read ID
    do
        case "$ID" in

            archive-004|archive-005|archive-007)
                prepare/archive/create-system-config.sh
                ;;

        esac
    done
}
