#!/usr/bin/env sh
docker build \
	--build-arg=GIT_REV="$(git rev-parse --short HEAD)" \
	--build-arg=GIT_BRANCH="$(git branch --show-current)" \
	--tag lyric_screen:latest \
	--file src/priv/dockerfile .
