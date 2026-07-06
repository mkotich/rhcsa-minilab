#!/bin/bash

prepare_timer() {
    install -D -m 755 \
        "$RHCSA_MINILAB_ROOT/assets/backup.sh" \
        /usr/local/bin/backup.sh
}
