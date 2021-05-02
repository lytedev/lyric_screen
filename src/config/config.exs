import Config

config :lyric_screen, compiled_at: DateTime.utc_now()
config :lyric_screen, env: Mix.env()
config :lyric_screen, ecto_repos: [LyricScreen.Repo]

config :lyric_screen, LyricScreen.Web.Endpoint,
	secret_key_base: "vqQv2ePi+neCxN9s7bwj508kWY06T7y4mijCyBrCz+xyXV/ozuHOMsSeNZ7OljJ9",
	render_errors: [view: LyricScreen.Web.ErrorView, accepts: ~w(html json), layout: false],
	pubsub_server: LyricScreen.PubSub,
	live_view: [signing_salt: "cmoCWK8M"],
	static_files_path: "src/priv/static"

config :lyric_screen, LyricScreen.Repo, priv: "src/priv/data"

config :logger, level: :debug

config :logger, :console,
	metadata: [:mfa, :line, :time],
	format: "\n[$level] $message\n\t#{IO.ANSI.color(8)}$metadata#{IO.ANSI.reset()}",
	colors: [enabled: true]

config :phoenix, :json_library, Jason

if config_env() == :dev do
	git_rev =
		case System.cmd("git", ~w{rev-parse --short HEAD}) do
			{out, 0} -> String.trim(out)
			{out, n} -> raise {"git rev-parse exited non-zero", n, out}
			err -> raise {"git rev-parse failed", err}
		end

	git_branch =
		case System.cmd("git", ~w{branch --show-current}) do
			{out, 0} -> String.trim(out)
			{out, n} -> raise {"git branch exited non-zero", n, out}
			err -> raise {"git branch failed", err}
		end

	config :lyric_screen,
		version_git_rev: git_rev,
		version_git_branch: git_branch

	config :lyric_screen, LyricScreen.Web.Endpoint,
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
	config :lyric_screen, LyricScreen.Web.Endpoint, server: false
	config :logger, level: :warn
end

if config_env() == :prod do
	config :lyric_screen, LyricScreen.Web.Endpoint,
		server: true,
		static_files_path: :lyric_screen

	config :logger, level: :info
	config :logger, :console,
		metadata: [:time, :level, :file, :function, :line, :mfa, :module, :pid, :request_id]
end
