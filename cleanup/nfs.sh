cleanup_nfs() {
    echo "Cleaning up NFS..."

    #
    # Unmount any NFS mounts
    #
    while read MOUNTPOINT; do
        umount -f "$MOUNTPOINT" 2> /dev/null
    done < <(
        mount -t nfs,nfs4 |
            awk '{print $3}'
    )

    #
    # Remove NFS entries from fstab
    #
    sed -i '\|server.rhcsa.local:/exports/share|d' /etc/fstab

    #
    # Stop NFS client services
    #
    systemctl disable --now nfs-client.target rpc-statd.service \
        > /dev/null 2>&1

    #
    # Remove stale NFS state
    #
    rm -rf /var/lib/nfs/*
}
