#!/bin/bash

set -e

scenario_web_httpd_read_user_content_disabled() {
    setsebool -P httpd_read_user_content off
}
