#!/usr/bin/env sh
set -e
source "$(dirname "$0")/helpers.sh"
export TERM=xterm
run_on_host ~/ls/bin/lyric_screen remote
