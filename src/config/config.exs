use Mix.Config

config :lyric_screen, compiled_at: DateTime.utc_now()
config :lyric_screen, env: Mix.env()

data_dir = "src/priv/data"
config :lyric_screen,
	playlists_dir: Path.join(data_dir, "playlists"),
	displays_dir: Path.join(data_dir, "displays"),
	songs_dir: Path.join(data_dir, "songs")

config :lyric_screen, LyricScreen.Web.Endpoint,
	url: [host: "localhost"],
	secret_key_base: "vqQv2ePi+neCxN9s7bwj508kWY06T7y4mijCyBrCz+xyXV/ozuHOMsSeNZ7OljJ9",
	render_errors: [view: LyricScreen.Web.ErrorView, accepts: ~w(html json), layout: false],
	pubsub_server: LyricScreen.PubSub,
	live_view: [signing_salt: "cmoCWK8M"],
	static_files_path: "src/priv/static"

config :logger, level: :debug

config :logger, :console,
	metadata: [:mfa, :line, :time],
	format: "\n[$level] $message\n\t#{IO.ANSI.color(8)}$metadata#{IO.ANSI.reset()}",
	colors: [enabled: true]

config :phoenix, :json_library, Jason

try do
	import_config "#{Mix.env()}.exs"
rescue
	_ -> :ok
end
