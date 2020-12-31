# LyricScreen

SaaS for managing live performance lyrics.

## Setup

```bash
mix deps.get
```

## Develop

```bash
iex -S mix phx.server
```

## Lint

```bash
mix dialyzer
mix credo --strict
```

## Test

```bash
mix test
```

## Generate Release

```bash
MIX_ENV=prod mix release
```

## Deploy

Generate a release first.

```bash
rsync -r build/rel/ $YOUR_HOST:~/my-app
ssh $YOUR_HOST \
	HOST=lyricscreen.com \
	PORT=80 \
	SECRET_KEY_BASE=$(pass lyricscreen.com/skb) \
	LIVE_VIEW_SALT=$(pass lyricscreen.com/lvs) \
	~/my-app/bin/lyric_screen daemon
```
