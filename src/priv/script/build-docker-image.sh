#!/usr/bin/env sh
v="$(cat mix.exs | grep '@version' | head -n 1 | cut -d '"' -f 2)"
docker build \
	--build-arg=GIT_REV="$(git rev-parse --short HEAD)" \
	--build-arg=GIT_BRANCH="$(git branch --show-current)" \
	--tag lytedev/lyric_screen:"$v" \
	--file src/priv/dockerfile .
docker push lytedev/lyric_screen:"$v"
