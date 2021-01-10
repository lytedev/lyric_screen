# LyricScreen

SaaS for managing live performance lyrics.

Demo at [http://alpha.lyricscreen.com:6754](http://alpha.lyricscreen.com:6754)

**NOTE**: This is a very alpha-level work-in-progress. It is possibly suitable for very basic on-premises single-user uses, but not much else.

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

```
./src/priv/script/deploy.sh
```
