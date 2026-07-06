#!/bin/bash

set -e

#
# Resource Group:
#     nfs
#
# Responsibilities:
#     - Install nfs-utils.
#     - Configure a working localhost-backed NFS server.
#     - Create sample export content.
#     - Configure firewall.
#     - Configure /etc/hosts for standalone mode.
#

prepare_nfs() {
    #
    # Install required packages.
    #
    dnf -y install nfs-utils > /dev/null 2>&1

    #
    # Create export.
    #
    mkdir -p /exports/share

    cat > /exports/share/README.txt << 'EOT'
RHCSA MiniLab NFS Share
EOT

    touch /exports/share/file{1..3}

    #
    # Configure exports.
    #
    cat > /etc/exports << 'EOT'
/exports/share *(rw,sync,no_root_squash)
EOT

    exportfs -rav > /dev/null 2>&1

    #
    # Standalone lab convenience.
    #
    if ! grep -q 'server.rhcsa.local' /etc/hosts; then
        echo "127.0.0.1 server.rhcsa.local server" >> /etc/hosts
    fi

    #
    # Firewall.
    #
    firewall-cmd --quiet --permanent --add-service=nfs
    firewall-cmd --quiet --permanent --add-service=mountd
    firewall-cmd --quiet --permanent --add-service=rpc-bind
    firewall-cmd --quiet --reload

    #
    # Enable services.
    #
    systemctl enable --now rpcbind > /dev/null 2>&1
    systemctl enable --now nfs-server > /dev/null 2>&1
}
