import Config

config :lyric_screen, compiled_at: DateTime.utc_now()
config :lyric_screen, env: Mix.env()

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
end

import_config("runtime.exs")
