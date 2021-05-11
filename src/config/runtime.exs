import Config

# data_dir = "src/priv/data"
app_dir = Path.dirname(__DIR__)
data_dir = System.get_env("DATA_DIR", Path.join(app_dir, "priv/data"))
app_subdir = &Path.join(app_dir, &1)
data_subdir = &Path.join(data_dir, &1)

env = &System.get_env(&1, &2)
path = &Path.expand(env.(&1, &2))

int = fn str, default ->
  case Integer.parse(env.(str, "")) do
    {n, _} when is_integer(n) -> n
    _ -> default
  end
end

config :lyric_screen, LyricScreen.Repo,
  database: env.("DATABASE_NAME", "lyrics_#{config_env()}"),
  username: env.("DATABASE_USER", "postgres"),
  password: env.("DATABASE_PASS", "postgres"),
  hostname: env.("DATABASE_HOST", "localhost"),
  port: int.("DATABASE_PORT", 5432)

default_port =
  case config_env() do
    :dev -> 4000
    :test -> 4002
    :prod -> 8899
  end

default_host =
  case config_env() do
    :dev -> "localhost"
    :test -> "localhost"
    :prod -> "lyricscreen.com"
  end

port = int.("PORT", default_port)
host = env.("HOST", default_host)

config :lyric_screen,
  chats_dir: path.("CHATS_DIR", data_subdir.("chats")),
  playlists_dir: path.("PLAYLISTS_DIR", data_subdir.("playlists")),
  displays_dir: path.("DISPLAYS_DIR", data_subdir.("displays")),
  songs_dir: path.("SONGS_DIR", data_subdir.("songs"))

config :lyric_screen, LyricScreen.Web.Endpoint,
  http: [port: port],
  url: [host: host]

if config_env() == :prod do
  secret = System.fetch_env!("SECRET_KEY_BASE")
  lv_salt = System.fetch_env!("LIVE_VIEW_SALT")

  config :lyric_screen,
    version_git_rev: env.("GIT_REV", "unk_git_rev"),
    version_git_branch: env.("GIT_BRANCH", "unk_git_branch")

  config :lyric_screen, LyricScreen.Web.Endpoint,
    url: [
      # scheme: "http",
      host: host,
      port: port
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
end
