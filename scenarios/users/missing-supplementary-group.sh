#!/bin/bash

set -e

scenario_users_missing_supplementary_group() {
    usermod \
        -G wheel \
        carol
}
