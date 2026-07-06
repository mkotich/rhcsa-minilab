#!/bin/bash

set -e

#
# Resource Group:
#     web
#
# Responsibilities:
#     - Install and configure Apache
#     - Deploy MiniLab web assets
#     - Restore SELinux web contexts
#
# Must NOT:
#     - Introduce intentional breakages
#

prepare_web() {
    web_install
    web_prepare_content
    web_configure
    web_prepare_selinux
    web_verify
}

web_install() {
    ensure_package httpd policycoreutils-python-utils

    ensure_service httpd
}

web_prepare_content() {
    ensure_directory /webdata
    ensure_directory /uploads

    deploy_asset httpd/index.html \
        /webdata/index.html
}

web_configure() {
    deploy_asset httpd/rhcsa-minilab.conf \
        /etc/httpd/conf.d/rhcsa-minilab.conf

    restart_service httpd
}

web_prepare_selinux() {
    semanage fcontext \
        -a \
        -t httpd_sys_content_t \
        "/webdata(/.*)?" > /dev/null 2>&1 ||
        semanage fcontext \
            -m \
            -t httpd_sys_content_t \
            "/webdata(/.*)?" > /dev/null

    semanage fcontext \
        -a \
        -t httpd_sys_rw_content_t \
        "/uploads(/.*)?" > /dev/null 2>&1 ||
        semanage fcontext \
            -m \
            -t httpd_sys_rw_content_t \
            "/uploads(/.*)?" > /dev/null

    restorecon -RF /webdata /uploads > /dev/null 2>&1
}

web_verify() {
    verify_service httpd

    verify_directory /webdata
    verify_directory /uploads

    verify_file /webdata/index.html

    verify_file /etc/httpd/conf.d/rhcsa-minilab.conf
}
