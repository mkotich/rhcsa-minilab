#!/bin/bash

#
# Scenario:
#     Wrong hostname
#

set -e

hostnamectl set-hostname backup.rhcsa.local > /dev/null 2>&1
