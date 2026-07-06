#!/bin/bash

for f in objectives/*.json
do
    jq empty "$f" >/dev/null || exit 1
done

jq -s 'add' objectives/*.json >/dev/null || exit 1

exit 0
