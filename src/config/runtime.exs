import Config

app_dir = Path.dirname(__DIR__)
data_dir = "src/priv/data"
data_dir = System.get_env("DATA_DIR", Path.join(app_dir, "priv/data"))
app_subdir = &Path.join(app_dir, &1)
data_subdir = &Path.join(data_dir, &1)

env = &System.get_env(&1, &2)
path = &Path.expand(env.(&1, &2))
int = fn (str, default) ->
	case Integer.parse(env.(str, "")) do
		{n, _} when is_integer(n) -> n
		_ -> default
	end
end

default_port =
	case config_env() do
		:dev -> 4000
		:test -> 4002
		:prod -> 8899
	end

config :lyric_screen,
	chats_dir: path.("CHATS_DIR", data_subdir.("chats")),
	playlists_dir: path.("PLAYLISTS_DIR", data_subdir.("playlists")),
	displays_dir: path.("DISPLAYS_DIR", data_subdir.("displays")),
	songs_dir: path.("SONGS_DIR", data_subdir.("songs"))

port = int.("PORT", default_port)
host = env.("HOST", "lyricscreen.com")

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

if config_env() == :dev do
	config :lyric_screen, LyricScreen.Web.Endpoint,
		http: [port: port],
		debug_errors: true,
		code_reloader: true,
		check_origin: false,
		watchers: [],
		live_reload: [
			patterns: [
				~r"src/priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
				~r"src/priv/gettext/.*(po)$",
				~r"src/lyric_screen/web/(live|views)/.*(ex)$",
				~r"src/lyric_screen/web/templates/.*(eex)$"
			]
		]

	config :phoenix, :stacktrace_depth, 20
	config :phoenix, :plug_init_mode, :runtime
end

if config_env() == :test do
	config :lyric_screen, LyricScreen.Web.Endpoint,
		http: [port: 4002],
		server: false

	config :logger, level: :warn
end

if config_env() == :prod do
	secret = System.fetch_env!("SECRET_KEY_BASE")
	lv_salt = System.fetch_env!("LIVE_VIEW_SALT")

	config :lyric_screen, LyricScreen.Web.Endpoint,
		server: true,
		static_files_path: :lyric_screen

	config :lyric_screen,
		version_git_rev: env.("GIT_REV", "unk_git_rev"),
		version_git_branch: env.("GIT_BRANCH", "unk_git_branch")

	config :logger, level: :info
	config :logger, :console,
		metadata: [:time, :level, :file, :function, :line, :mfa, :module, :pid, :request_id]

	config :lyric_screen, LyricScreen.Web.Endpoint,
		url: [
			# scheme: "http",
			host: host,
			port: port,
			# path: "/",
		],
		http: [
			port: port,
			# transport_options: [socket_opts: [:inet6]]
			transport_options: [socket_opts: [:inet]]
		],
		secret_key_base: secret,
		live_view: [signing_salt: lv_salt],
		server: true
end
