use Mix.Config

config :lyric_screen, LyricScreen.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :lyric_screen, LyricScreen.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r"src/priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"src/priv/gettext/.*(po)$",
      ~r"src/lyric_screen/web/(live|views)/.*(ex)$",
      ~r"src/lyric_screen/web/templates/.*(eex)$"
    ]
  ]

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
