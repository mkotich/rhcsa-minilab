#!/bin/bash

verify_root()
{
    if [ "$EUID" -ne 0 ]
    then
        echo "ERROR: Must be run as root."
        exit 1
    fi
}

verify_root

BASELINE=/baseline

echo
echo "Creating baseline..."
echo

mkdir -p "$BASELINE"

rsync -aAXH --delete \
    --exclude="$BASELINE" \
    --exclude=/home/student \
    --exclude=/opt/rhcsa-minilab \
    --exclude=/dev \
    --exclude=/proc \
    --exclude=/sys \
    --exclude=/run \
    --exclude=/tmp \
    --exclude=/var/lib/nfs/rpc_pipefs \
    --exclude=/var/tmp \
    --exclude=/mnt \
    --exclude=/media \
    --exclude=/lost+found \
    / "$BASELINE"

git rev-parse HEAD > /baseline.version

echo
echo "Baseline created successfully."
echo "Commit: $(cat /baseline.version)"
echo
