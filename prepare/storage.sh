#!/bin/bash

set -e

#
# Resource Group:
#     storage
#

prepare_storage()
{
    test -b /dev/sdb
}
