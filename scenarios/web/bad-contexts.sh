#!/bin/bash

set -e

#
# Resource Group:
#     web
#
# Scenario:
#     bad-contexts
#

scenario_web_bad_contexts()
{
    chcon -Rt default_t /webdata
    chcon -Rt default_t /uploads
}
