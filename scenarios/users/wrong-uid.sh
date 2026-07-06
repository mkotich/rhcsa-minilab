#!/bin/bash

set -e

scenario_users_wrong_uid() {
    usermod \
        -u 5002 \
        carol
}
