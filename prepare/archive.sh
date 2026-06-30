#!/bin/bash

set -e

#
# Resource Group:
#     archive
#
# Responsibilities:
#     - Create baseline archive files.
#     - Remove extracted content from previous exams.
#

prepare_archive()
{
    mkdir -p /restore

    rm -rf /restore/*
    rm -f \
        /root/etc-files.txt \
        /root/etc-no-ssh.tar.gz

    tar -czf /root/etc.tar.gz /etc >/dev/null 2>&1
    tar -cjf /root/home.tar.bz2 /home >/dev/null 2>&1
    tar -cJf /root/varlog.tar.xz /var/log >/dev/null 2>&1
}
