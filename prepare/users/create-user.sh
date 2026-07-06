#!/bin/bash

set -e

#
# users-002 .. users-005
#

id alice > /dev/null 2>&1 &&
    userdel -rf alice > /dev/null 2>&1 || true
