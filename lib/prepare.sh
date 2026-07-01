#!/bin/bash

#
# Common helper functions for preparation modules.
#

ensure_package()
{
    dnf -y install "$@" >/dev/null
}

refresh_package_metadata()
{
    dnf makecache >/dev/null
}

ensure_service()
{
    systemctl enable --now "$1" >/dev/null 2>&1
}

restart_service()
{
    systemctl restart "$1" >/dev/null 2>&1
}

verify_service()
{
    systemctl is-active --quiet "$1"
}

ensure_directory()
{
    install -d -m "${2:-0755}" "$1"
}

deploy_asset()
{
    install -D -m 0644 \
        "$RHCSA_MINILAB_ROOT/assets/$1" \
        "$2"
}

verify_file()
{
    test -f "$1"
}

verify_directory()
{
    test -d "$1"
}

verify_block_device()
{
    test -b "$1"
}
