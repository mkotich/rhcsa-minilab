#!/bin/bash

set -e

scenario_users_wrong_shell()
{
    usermod \
        -s /sbin/nologin \
        carol
}
