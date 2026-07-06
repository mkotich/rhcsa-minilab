#!/bin/bash

set -e

scenario_web_httpd_use_nfs_disabled() {
    setsebool -P httpd_use_nfs off
}
