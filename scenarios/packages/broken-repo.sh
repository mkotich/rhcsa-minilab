#!/bin/bash

set -e

#
# Resource Group:
#     packages
#
# Scenario:
#     broken-repo
#
# Purpose:
#     Corrupt the MiniLab repository configuration.
#

scenario_packages_broken_repo() {
    sed -i \
        's|^baseurl=.*|baseurl=http://invalid.example.invalid/BaseOS|' \
        /etc/yum.repos.d/rhcsa-minilab.repo
}
