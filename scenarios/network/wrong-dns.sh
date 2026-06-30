#!/bin/bash

#
# Scenario:
#     Wrong DNS server
#

set -e

IFACE=$(ip route | awk '/default/ {print $5; exit}')

nmcli connection modify "$IFACE" ipv4.dns "1.1.1.1" >/dev/null 2>&1
nmcli connection up "$IFACE" >/dev/null 2>&1
