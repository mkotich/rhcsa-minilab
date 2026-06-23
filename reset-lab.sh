#!/bin/bash

echo
echo "Resetting client..."
echo

#
# Remove exam artifacts
#
rm -f /home/student/EXAM.txt
rm -f /home/student/exam-state.json

#
# Storage cleanup
#

# Disable any student-created swap
swapoff -a >/dev/null 2>&1

# Unmount common mountpoints
for MOUNT in \
    /archive \
    /apps \
    /backup \
    /data
do
    umount -lf "$MOUNT" >/dev/null 2>&1
done

# Deactivate student logical volumes
lvchange -an vgarchive/lvarchive >/dev/null 2>&1
lvchange -an vgapps/lvapps >/dev/null 2>&1
lvchange -an vgdata/lvdata >/dev/null 2>&1
lvchange -an vgswap/lvswap >/dev/null 2>&1

# Remove student logical volumes
lvremove -fy vgarchive/lvarchive >/dev/null 2>&1
lvremove -fy vgapps/lvapps >/dev/null 2>&1
lvremove -fy vgdata/lvdata >/dev/null 2>&1
lvremove -fy vgswap/lvswap >/dev/null 2>&1

# Remove student volume groups
vgremove -fy vgarchive >/dev/null 2>&1
vgremove -fy vgapps >/dev/null 2>&1
vgremove -fy vgdata >/dev/null 2>&1
vgremove -fy vgswap >/dev/null 2>&1

# Remove student PV metadata
pvremove -ffy /dev/sdb1 >/dev/null 2>&1
pvremove -ffy /dev/sdb >/dev/null 2>&1

# Remove partition table and signatures
wipefs -af /dev/sdb >/dev/null 2>&1

# Re-read partition table
partprobe /dev/sdb >/dev/null 2>&1
udevadm settle >/dev/null 2>&1

#
# Restore baseline
#
rsync -aAXH --delete \
    --exclude=/baseline \
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
    --exclude=/home/student \
    --exclude=/opt/rhcsa-minilab \
    /baseline/ /

systemctl daemon-reload

echo
echo "Client reset complete."
echo
