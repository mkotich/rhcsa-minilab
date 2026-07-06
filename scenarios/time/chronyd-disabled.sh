#!/bin/bash

set -e

scenario_time_chronyd_stopped_disabled() {
    #
    # Disable and stop Chrony.
    #
    systemctl disable chronyd > /dev/null 2>&1 || true
    systemctl stop chronyd > /dev/null 2>&1 || true
}
