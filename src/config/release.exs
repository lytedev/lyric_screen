import Config

app_dir = Application.app_dir(:lyric_screen)
app_subdir = fn (s) -> Path.join(app_dir, s) end

str = fn (s, default) -> s |> System.get_env(default) end
path = fn (s, default) -> str.(s, default) |> Path.expand() end
int = fn (s, default) -> s |> str.(Integer.to_string(default)) |> String.to_integer() || default end

config :lyric_screen,
	chats_dir: path.("CHATS_DIR", app_subdir.("priv/data/chats")),
	playlists_dir: path.("PLAYLISTS_DIR", app_subdir.("priv/data/playlists")),
	displays_dir: path.("DISPLAYS_DIR", app_subdir.("priv/data/displays")),
	songs_dir: path.("SONGS_DIR", app_subdir.("priv/data/songs"))

port = int.("PORT", 8899)
host = str.("HOST", "lyricscreen.com")
secret = System.fetch_env!("SECRET_KEY_BASE")
lv_salt = System.fetch_env!("LIVE_VIEW_SALT")

IO.puts("configuration, baby: #{inspect({port, host})}")

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
