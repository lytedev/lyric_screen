# Lyricscreen

Demo at [http://alpha.lyricscreen.com:6754](http://alpha.lyricscreen.com:6754)

![Screenshot of LyricScreen index page][ss_index]

![Screenshot of LyricScreen control panel page][ss_controlpanel]

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


[ss_index]: https://files.lyte.dev/uploads/lyric_screen_index.png
[ss_controlpanel]: https://files.lyte.dev/uploads/lyric_screen_controlpanel.png
>>>>>>> 43f47c2e4394be4162dc1acc0432f06ba79b9b96
