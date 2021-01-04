#!/usr/bin/env sh

set -e

env MIX_ENV=prod mix release --overwrite
source "$(dirname "$0")/helpers.sh"

rsync -IPr build/rel/ "$REMOTE_HOST:~/ls"

run_on_host ~/ls/bin/lyric_screen stop || true
run_on_host ~/ls/bin/lyric_screen start_iex
