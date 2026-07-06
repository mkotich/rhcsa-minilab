#!/bin/bash

set -e

prepare_process() {
    mkdir -p /var/lib/rhcsa-minilab

    #
    # Remove any previous lab process.
    #
    if [ -f /var/lib/rhcsa-minilab/rhcsa-sleep.pid ]; then
        kill "$(cat /var/lib/rhcsa-minilab/rhcsa-sleep.pid)" \
            > /dev/null 2>&1 || true
    fi

    #
    # Start the lab process.
    #
    bash -c 'exec -a rhcsa-sleep sleep infinity' &
    echo $! > /var/lib/rhcsa-minilab/rhcsa-sleep.pid
}
