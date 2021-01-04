use Mix.Config

config :lyric_screen, compiled_at: DateTime.utc_now()

git_rev =
	case System.cmd("git", ~w{rev-parse --short HEAD}) do
		{out, 0} -> String.trim(out)
		{out, n} -> raise "git rev-parse exited non-zero"
		err -> raise "git rev-parse failed"
	end

git_branch =
	case System.cmd("git", ~w{branch --show-current}) do
		{out, 0} -> String.trim(out)
		{out, n} -> raise "git branch exited non-zero"
		err -> raise "git branch failed"
	end

config :lyric_screen,
	version_git_rev: git_rev,
	version_git_branch: git_branch

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
