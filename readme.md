# Lyricscreen

SaaS for managing live performance lyrics.

Demo at [http://alpha.lyricscreen.com:6754](http://alpha.lyricscreen.com:6754)

![Screenshot of LyricScreen index page][ss_index]

![Screenshot of LyricScreen control panel page][ss_controlpanel]

**NOTE**: This is a very alpha-level work-in-progress. It is possibly suitable for very basic on-premises single-user uses, but not much else, but since documentation is extremely spartan, you will likely need to figure things out on your own. If you file an issue, I'll get to it!

## On Docker Hub

https://hub.docker.com/repository/docker/lytedev/lyric_screen

### Example

```
export SECRET_KEY="$(mix phx.gen.secret)"
export LIVE_VIEW_SALT="$(mix phx.gen.secret)"
# save your secret key and salt!
docker run \
  --env SECRET_KEY_BASE="$SECRET_KEY" \
  --env LIVE_VIEW_SALT="$LIVE_VIEW_SALT" \
	--env DATA_DIR="/opt/lyric_screen/data" \
	--env HOST="localhost" \
	--env PORT="4000" \
	-p 4000:4000/tcp \
	--volume "lyric_screen_data:/opt/lyric_screen/data" \
	--name lyric_screen \
	lytedev/lyric_screen:0.5.4
# avoid using latest in production
```

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

# Documentation & Notes

## Data Structure

At some point, the data needs to move beyond flat files.

+ **Organization**: Has one or more associated users
	+ Users
	+ Performances
	+ Payment information?
+ **User**: A single user of the application. May be associated with multiple organizations by different roles.
	+ Name
	+ Avatar
	+ Status (what is the user currently doing? which performance/display are they managing?)
	+ Contact Information
	+ Authentication Credentials
	+ **Note**: Anonymous user support could be enabled fairly trivially using magic links
+ **Performance**: Has one or more associated displays
	+ Name
	+ Date/Time?
	+ Displays
	+ Anything else?
+ **Displays**: Encapsulate the state of a display (which song is up? which verse in that song?)
	+ Name
	+ Properties (show custom backgrounds, show lyrics, show chords, etc.)
	+ Playlist
	+ Active Song
	+ Active Map
	+ Active Verse
	+ Other Display State (hidden, frozen, etc.)
+ **Playlist**: A list of songs to go through for a performance and their chosen maps.
	+ Name
	+ Songs
	+ Maps
+ **Song**: A collection of verses.
	+ Name
	+ Metadata (album art? copyright? etc.)
	+ Verses
+ **Map**: A specific ordering of verses for a particular song.
	+ Song
	+ Verses
+ **Verse**: A small (usually a few lines) of text associated with a part of a song.
	+ Name
	+ Content


[ss_index]: https://files.lyte.dev/uploads/lyric_screen_index.png
[ss_controlpanel]: https://files.lyte.dev/uploads/lyric_screen_controlpanel.png
