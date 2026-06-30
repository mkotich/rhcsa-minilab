#!/bin/bash

set -e

#
# Resource Group:
#     packages
#

prepare_packages()
{
    dnf makecache >/dev/null
}
