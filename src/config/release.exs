import Config

app_dir = Application.app_dir(:lyric_screen)
app_subdir = fn (s) -> Path.join(app_dir, s) end
config :lyric_screen,
	chats_dir: app_subdir.("priv/data/chats"),
	playlists_dir: app_subdir.("priv/data/playlists"),
	displays_dir: app_subdir.("priv/data/displays"),
	songs_dir: app_subdir.("priv/data/songs")

str = fn (s, default) -> s |> System.get_env(default) end
int = fn (s, default) -> s |> str.(Integer.to_string(default)) |> String.to_integer() || default end

port = int.("PORT", 8899)
host = str.("HOST", "lyricscreen.com")
secret = System.fetch_env!("SECRET_KEY_BASE")
lv_salt = System.fetch_env!("LIVE_VIEW_SALT")

IO.puts("configuration, baby: #{inspect({port, host})}")

config :lyric_screen, LyricScreen.Web.Endpoint,
	static_files_path: "priv/static",
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
