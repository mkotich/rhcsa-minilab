#!/bin/bash

set -e

scenario_users_locked_account()
{
    passwd -l carol >/dev/null
}
