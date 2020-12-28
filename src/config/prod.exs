use Mix.Config

config :lyric_screen, LyricScreen.Web.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "src/priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
