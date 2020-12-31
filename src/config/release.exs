import Config

str = fn (s, default) -> s |> System.get_env(default) end
int = fn (s, default) -> s |> str.(Integer.to_string(default)) |> String.to_integer() || default end

port = int.("PORT", 8899)
host = str.("HOST", "lyricscreen.com")
secret = System.fetch_env!("SECRET_KEY_BASE")
lv_salt = System.fetch_env!("LIVE_VIEW_SALT")

IO.puts("configuration, baby: #{inspect({port, host})}")

config :lyric_screen, LyricScreen.Web.Endpoint,
	url: [
		port: port,
		host: host,
		# transport_options: [socket_opts: [:inet6]]
	],
	secret_key_base: secret,
	live_view: [signing_salt: lv_salt],
	server: true
