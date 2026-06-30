#!/bin/bash

set -e

#
# Resource Group:
#     nfs
#

prepare_nfs()
{
    ensure_package nfs-utils

    ensure_service nfs-server

    verify_service nfs-server
}
