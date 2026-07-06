#!/bin/bash

scenario_time_chronyd_stopped_disabled() {

    systemctl stop chronyd >/dev/null 2>&1 || true
    systemctl disable chronyd >/dev/null 2>&1 || true

}
