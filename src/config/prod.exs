use Mix.Config

config :logger, level: :info
config :logger, :console,
	metadata: [:time, :level, :file, :function, :line, :mfa, :module, :pid, :request_id]

config :lyric_screen, LyricScreen.Web.Endpoint,
	server: true,
	static_files_path: :lyric_screen
