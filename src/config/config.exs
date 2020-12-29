use Mix.Config

config :lyric_screen,
	chats_dir: "src/priv/data/chats",
	playlists_dir: "src/priv/data/playlists",
	displays_dir: "src/priv/data/displays",
	songs_dir: "src/priv/data/songs"

config :lyric_screen, LyricScreen.Web.Endpoint,
	url: [host: "localhost"],
	secret_key_base: "vqQv2ePi+neCxN9s7bwj508kWY06T7y4mijCyBrCz+xyXV/ozuHOMsSeNZ7OljJ9",
	render_errors: [view: LyricScreen.Web.ErrorView, accepts: ~w(html json), layout: false],
	pubsub_server: LyricScreen.PubSub,
	live_view: [signing_salt: "cmoCWK8M"]

config :logger, level: :debug

config :logger, :console,
	metadata: [:mfa, :line, :level, :time],
	format: "	=> $metadata\n$message\n\n",
	colors: [enabled: true]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
