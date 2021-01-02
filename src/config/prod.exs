use Mix.Config

app_dir = Application.app_dir(:lyric_screen)
app_subdir = fn (s) -> Path.join(app_dir, s) end
config :lyric_screen,
	chats_dir: app_subdir.("data/chats"),
	playlists_dir: app_subdir.("data/playlists"),
	displays_dir: app_subdir.("data/displays"),
	songs_dir: app_subdir.("data/songs")

config :logger, level: :info
config :logger, :console,
	metadata: [:time, :level, :file, :function, :line, :mfa, :module, :pid, :request_id]

config :lyric_screen, LyricScreen.Web.Endpoint,
	server: true,
	static_files_path: "priv/static"
