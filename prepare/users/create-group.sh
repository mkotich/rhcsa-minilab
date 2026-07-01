#!/bin/bash

set -e

#
# users-001
#

getent group developers >/dev/null &&
    groupdel developers >/dev/null 2>&1 || true
