import Config

app_dir = Application.app_dir(:lyric_screen)
data_dir = System.get_env("DATA_DIR", Path.join(app_dir, "priv/data"))
app_subdir = fn (s) -> Path.join(app_dir, s) end
data_subdir = fn (s) -> Path.join(data_dir, s) end

str = fn (s, default) -> s |> System.get_env(default) end
path = fn (s, default) -> str.(s, default) |> Path.expand() end
int = fn (s, default) -> s |> str.(Integer.to_string(default)) |> String.to_integer() || default end

config :lyric_screen,
	chats_dir: path.("CHATS_DIR", data_subdir.("chats")),
	playlists_dir: path.("PLAYLISTS_DIR", data_subdir.("playlists")),
	displays_dir: path.("DISPLAYS_DIR", data_subdir.("displays")),
	songs_dir: path.("SONGS_DIR", data_subdir.("songs"))

port = int.("PORT", 8899)
host = str.("HOST", "lyricscreen.com")
secret = System.fetch_env!("SECRET_KEY_BASE")
lv_salt = System.fetch_env!("LIVE_VIEW_SALT")

IO.puts("Host Config: #{inspect({port, host})}")

config :lyric_screen,
	version_git_rev: System.get_env("GIT_REV", "unk_git_rev"),
	version_git_branch: System.get_env("GIT_BRANCH", "unk_git_branch")

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
