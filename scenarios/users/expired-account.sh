#!/bin/bash

set -e

scenario_users_expired_account() {
    chage \
        -E 2024-01-01 \
        carol
}
