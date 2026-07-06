#!/bin/bash

#
# expand_objectives
#
# Reads one or more objective JSON files, merges them into a single
# array, expands template variables, and writes the expanded JSON
# to stdout.
#
# Usage:
#
#     expand_objectives objectives/*.json
#
expand_objectives() {
    jq -cs '
        add
        | map(
            if .answer.grow_by? == "${SIZE}" then
                . as $obj
                | (["256MiB","512MiB","1GiB"] | .[now|floor % length]) as $size
                | $obj
                | .text |= (split("${SIZE}") | join($size))
                | .answer.grow_by = $size
            else
                .
            end
        )
    ' "$@"
}
