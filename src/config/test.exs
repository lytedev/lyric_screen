use Mix.Config

config :lyric_screen, LyricScreen.Web.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
