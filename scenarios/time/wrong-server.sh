#!/bin/bash

set -e

#
# Resource Group:
#     time
#
# Scenario:
#     wrong-server
#
# Purpose:
#     Configure chrony to use an invalid time source.
#

scenario_time_wrong_server() {
    sed -i \
        's/^server .*/server 192.0.2.1 iburst/' \
        /etc/chrony.conf

    systemctl restart chronyd > /dev/null 2>&1
}
