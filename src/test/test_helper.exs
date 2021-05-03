LyricScreen.Repo.__adapter__().storage_up(LyricScreen.Repo.config())
migrations_path = Application.get_env(:lyric_screen, LyricScreen.Repo)[:priv]
Ecto.Migrator.run(LyricScreen.Repo, migrations_path, :up, all: true)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(LyricScreen.Repo, :manual)
