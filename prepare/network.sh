#!/bin/bash

set -e

#
# Resource Group:
#     network
#

prepare_network()
{
    ensure_service NetworkManager

    verify_service NetworkManager
}
