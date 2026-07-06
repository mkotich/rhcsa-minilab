cleanup_storage() {
    #
    # Disable swap
    #
    swapoff -a > /dev/null 2>&1

    #
    # Unmount common RHCSA mountpoints
    #
    for MOUNT in \
        /archive \
        /apps \
        /backup \
        /data; do
        umount "$MOUNT" > /dev/null 2>&1
    done

    #
    # Remove logical volumes
    #
    lvremove -fy vgarchive/lvarchive > /dev/null 2>&1
    lvremove -fy vgapps/lvapps > /dev/null 2>&1
    lvremove -fy vgdata/lvdata > /dev/null 2>&1
    lvremove -fy vgswap/lvswap > /dev/null 2>&1

    #
    # Remove volume groups
    #
    vgremove -fy vgarchive > /dev/null 2>&1
    vgremove -fy vgapps > /dev/null 2>&1
    vgremove -fy vgdata > /dev/null 2>&1
    vgremove -fy vgswap > /dev/null 2>&1

    #
    # Remove PV metadata
    #
    pvremove -ffy /dev/sdb > /dev/null 2>&1

    #
    # Remove partition tables and signatures
    #
    sgdisk --zap-all /dev/sdb > /dev/null 2>&1

    wipefs -a /dev/sdb > /dev/null 2>&1

    partprobe /dev/sdb > /dev/null 2>&1
}
