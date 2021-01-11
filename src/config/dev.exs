use Mix.Config

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
	http: [port: 4000],
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
