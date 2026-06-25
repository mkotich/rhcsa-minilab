#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/variables.conf"

#
# rhcsa-minilab system-prep.sh
#

verify_root()
{
    if [ "$EUID" -ne 0 ]
    then
        fail "Must be run as root."
    fi
}

source ./variables.conf

########################################
# Common Functions
########################################

fail()
{
    echo
    echo "ERROR: $1"
    echo
    exit 1
}

########################################
# Server Functions
########################################

prep_server()
{
    echo
    echo "Preparing server..."
    echo

    configure_server_network
    configure_hosts_file
    install_server_packages
    if [ "$LAB_MODE" = "full" ]
    then
        configure_http_repo
        configure_nfs
    fi
    configure_firewall

    echo
    echo "Server preparation complete."
    echo
}

########################################
# Client Functions
########################################

prep_client()
{
    echo
    echo "Preparing client..."
    echo

    configure_client_network
    configure_hosts_file
    configure_client_repos
    install_client_packages

    echo
    echo "Client preparation complete."
    echo
}

########################################
# Placeholder Functions
########################################

configure_server_network()
{
    echo "Configuring server network..."

    nmcli con modify "$SERVER_IFACE" \
        ipv4.addresses "${SERVER_IP}/${PREFIX}" \
        ipv4.gateway "${GATEWAY}" \
        ipv4.dns "${DNS}" \
        ipv4.method manual

    nmcli con up "$SERVER_IFACE"
}

configure_client_network()
{
    echo "Configuring client network..."

    nmcli con modify "$CLIENT_IFACE" \
        ipv4.addresses "${CLIENT_IP}/${PREFIX}" \
        ipv4.gateway "${GATEWAY}" \
        ipv4.dns "${DNS}" \
        ipv4.method manual

    nmcli con up "$CLIENT_IFACE"
}

configure_hosts_file()
{
    echo "Configuring /etc/hosts..."

    cat > /etc/hosts << EOF
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6

${SERVER_IP} ${SERVER_FQDN} ${SERVER_HOSTNAME}
${CLIENT_IP} ${CLIENT_FQDN} ${CLIENT_HOSTNAME}
EOF
}

install_server_packages()
{
    echo "Installing server packages..."

    dnf install -y \
        httpd \
        nfs-utils

    systemctl enable --now httpd
    systemctl enable --now nfs-server
}

install_client_packages()
{
    echo "Installing client packages..."

    dnf install -y \
        bash-completion \
        vim-enhanced
}

configure_http_repo()
{
    echo "Configuring HTTP repository..."

    mkdir -p /mnt/iso

    if ! mountpoint -q /mnt/iso
    then
        mount "$ISO_DEVICE" /mnt/iso
    fi

    if [ ! -d "${REPO_ROOT}/BaseOS" ]
    then
        cp -a /mnt/iso/BaseOS "$REPO_ROOT"
    fi

    if [ ! -d "${REPO_ROOT}/AppStream" ]
    then
        cp -a /mnt/iso/AppStream "$REPO_ROOT"
    fi
}

configure_nfs()
{
    echo "Configuring NFS..."

    mkdir -p "$NFS_EXPORT"

    cat > /etc/exports << EOF
${NFS_EXPORT} *(rw,sync)
EOF

    exportfs -rav
}

configure_firewall()
{
    echo "Configuring firewall..."

    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=nfs
    firewall-cmd --permanent --add-service=mountd
    firewall-cmd --permanent --add-service=rpc-bind

    firewall-cmd --reload
}

configure_client_repos()
{
    echo "Configuring client repositories..."

    if [ "$LAB_MODE" = "full" ]
    then
        rm -f /etc/yum.repos.d/*.repo

        cat > /etc/yum.repos.d/rhcsa-minilab.repo << EOF
[BaseOS]
name=BaseOS
baseurl=${SERVER_HTTP_REPO}/BaseOS
enabled=1
gpgcheck=0

[AppStream]
name=AppStream
baseurl=${SERVER_HTTP_REPO}/AppStream
enabled=1
gpgcheck=0
EOF

        dnf clean all
        dnf makecache
    else
        echo "Standalone mode: leaving existing repositories unchanged."
    fi
}

########################################
# Status Functions
########################################

server_status()
{
    echo
    echo "SERVER"
    echo "------"

    echo "Hostname ............. PASS"

    if systemctl is-active --quiet httpd
    then
        echo "HTTPD ................ PASS"
    else
        echo "HTTPD ................ FAIL"
    fi

    if systemctl is-active --quiet nfs-server
    then
        echo "NFS Server ........... PASS"
    else
        echo "NFS Server ........... FAIL"
    fi

    if [ -f "${REPO_ROOT}/BaseOS/repodata/repomd.xml" ]
    then
        echo "BaseOS Repo .......... PASS"
    else
        echo "BaseOS Repo .......... FAIL"
    fi

    if [ -f "${REPO_ROOT}/AppStream/repodata/repomd.xml" ]
    then
        echo "AppStream Repo ....... PASS"
    else
        echo "AppStream Repo ....... FAIL"
    fi

    if exportfs -v | grep -q "${NFS_EXPORT}"
    then
        echo "NFS Export ........... PASS"
    else
        echo "NFS Export ........... FAIL"
    fi
}

client_status()
{
    echo
    echo "CLIENT"
    echo "------"

    echo "Hostname ............. PASS"

    if [ -b "$CLIENT_EXTRA_DISK" ]
    then
        echo "Extra Disk ........... PASS"
    else
        echo "Extra Disk ........... FAIL"
    fi

    if curl -s "${SERVER_HTTP_REPO}/BaseOS/repodata/repomd.xml" >/dev/null
    then
        echo "BaseOS Repo .......... PASS"
    else
        echo "BaseOS Repo .......... FAIL"
    fi

    if curl -s "${SERVER_HTTP_REPO}/AppStream/repodata/repomd.xml" >/dev/null
    then
        echo "AppStream Repo ....... PASS"
    else
        echo "AppStream Repo ....... FAIL"
    fi

    if ping -c1 -W1 server >/dev/null 2>&1
    then
        echo "Server Reachable ..... PASS"
    else
        echo "Server Reachable ..... FAIL"
    fi
}

show_status()
{
    echo
    echo "rhcsa-minilab status"
    echo "===================="

    if [ "$SHORT_HOSTNAME" = "$SERVER_HOSTNAME" ]
    then
        server_status

    elif [ "$SHORT_HOSTNAME" = "$CLIENT_HOSTNAME" ]
    then
        client_status

    else
        fail "Unknown hostname: $HOSTNAME"
    fi

    echo
    echo "OVERALL"
    echo "-------"
    echo "Ready for Exam ....... YES"
    echo
}

########################################
# Main
########################################

verify_root

HOSTNAME=$(hostnamectl --static)
SHORT_HOSTNAME=${HOSTNAME%%.*}

case "$1" in
    --status)
        show_status
        ;;

    "")
    if [ "$LAB_MODE" = "full" ] &&
       [ "$SHORT_HOSTNAME" = "$SERVER_HOSTNAME" ]
    then
        prep_server

    elif [ "$SHORT_HOSTNAME" = "$CLIENT_HOSTNAME" ]
    then
        prep_client

    else
        fail "Unknown hostname: $HOSTNAME"
    fi

        elif [ "$SHORT_HOSTNAME" = "$CLIENT_HOSTNAME" ]
        then
            prep_client

        else
            fail "Unknown hostname: $HOSTNAME"
        fi
        ;;

    *)
        fail "Usage: $0 [--status]"
        ;;
esac

