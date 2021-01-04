#!/usr/bin/env sh

export REMOTE_HOST="$(pass servers/lyricscreen/ssh-host)"
run_on_host() {
	echo "Running $@ on $REMOTE_HOST ..."
	ssh "$REMOTE_HOST" \
		HOST=alpha.lyricscreen.com \
		PORT=6754 \
		CHATS_DIR=~/ls/data/playlists \
		PLAYLISTS_DIR=~/ls/data/playlists \
		DISPLAYS_DIR=~/ls/data/displays \
		SONGS_DIR=~/ls/data/songs \
		SECRET_KEY_BASE=$(pass servers/lyricscreen/secret-key-base) \
		LIVE_VIEW_SALT=$(pass servers/lyricscreen/live-view-salt) \
		"$@"
}
export -f run_on_host
