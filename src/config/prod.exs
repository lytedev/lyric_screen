use Mix.Config

config :lyric_screen, LyricScreen.Web.Endpoint,
	url: [
		host: "example.com",
		port: 80,
		# transport_options: [socket_opts: [:inet6]],
	],
	server: true

config :logger, level: :info

config :logger, :console,
	metadata: [:time, :level, :file, :function, :line, :mfa, :module, :pid, :request_id],
	format: "$metadata\n$message\n\n",
	colors: [enabled: true]
