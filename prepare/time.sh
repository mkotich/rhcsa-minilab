#!/bin/bash

set -e

#
# Resource Group:
#     time
#

prepare_time() {
    ensure_package chrony

    ensure_service chronyd

    verify_service chronyd
}
