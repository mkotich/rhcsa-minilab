#!/bin/bash

#
# rhcsa-minilab system-prep.sh
#

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
    configure_http_repo
    configure_nfs
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
    echo "Configure server network"
}

configure_client_network()
{
    echo "Configure client network"
}

configure_hosts_file()
{
    echo "Configuring /etc/hosts..."

    cat > /etc/hosts << EOF
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6

${SERVER_IP} ${SERVER_HOSTNAME}
${CLIENT_IP} ${CLIENT_HOSTNAME}
EOF
}
configure_hosts_file()
{
    echo "Configuring /etc/hosts..."

    cat > /etc/hosts << EOF
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6

${SERVER_IP} ${SERVER_HOSTNAME}
${CLIENT_IP} ${CLIENT_HOSTNAME}
EOF
}

install_server_packages()
{
    echo "Install server packages"
}

install_client_packages()
{
    echo "Install client packages"
}

configure_http_repo()
{
    echo "Configure HTTP repository"
}

configure_nfs()
{
    echo "Configure NFS"
}

configure_firewall()
{
    echo "Configure firewall"
}

configure_client_repos()
{
    echo "Configure client repos"
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
}

client_status()
{
    echo
    echo "CLIENT"
    echo "------"

    if [ -b "${CLIENT_EXTRA_DISK}" ]
    then
        echo "Extra disk ........... PASS"
    else
        echo "Extra disk ........... FAIL"
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
}

########################################
# Main
########################################

HOSTNAME=$(hostnamectl --static)
SHORT_HOSTNAME=${HOSTNAME%%.*}

case "$1" in
    --status)
        show_status
        ;;

    "")
        if [ "$SHORT_HOSTNAME" = "$SERVER_HOSTNAME" ]
        then
            prep_server

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

