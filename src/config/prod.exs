use Mix.Config

config :lyric_screen, LyricScreen.Web.Endpoint,
	url: [host: "example.com", port: 80],
	cache_static_manifest: "src/priv/static/cache_manifest.json"

config :logger, level: :info

config :logger, :console,
	metadata: [:time, :level, :file, :function, :line, :mfa, :module, :pid, :request_id],
	format: "$metadata\n$message\n\n",
	colors: [enabled: true]

import_config "prod.secret.exs"
