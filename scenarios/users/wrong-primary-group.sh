#!/bin/bash

set -e

scenario_users_wrong_primary_group()
{
    groupadd -f users

    usermod \
        -g users \
        carol
}
