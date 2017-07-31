#!/bin/bash

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log 101
log 10

log "test.sh test log function call" 1

log 11
log 101

exit 0 
