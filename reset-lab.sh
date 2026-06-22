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

echo
echo "Resetting client..."
echo

rm -f /home/student/EXAM.txt
rm -f /home/student/exam-state.json

rsync -aAXH --delete \
    --exclude=/baseline \
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
    /baseline/ /

systemctl daemon-reload

echo
echo "Client reset complete."
echo
