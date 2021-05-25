defmodule LyricScreen.MixProject do
  use Mix.Project

  @version "0.5.6"

  @src_path "src"
  @priv_path Path.join(@src_path, "priv")
  @config_dir_path Path.join(@src_path, "config")
  @config_path Path.join(@config_dir_path, "config.exs")
  @test_path Path.join(@src_path, "test")
  @build_path "build"
  @deps_path Path.join(@build_path, "deps")
  @docs_path Path.join(@build_path, "docs")

  defp deps,
    do: [
      {:ash, "~> 1.44.8"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:phoenix, "~> 1.5.6"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_view, "~> 0.15.1"},
      {:phoenix_slime, "~> 0.13.1"},
      {:ecto_ulid, "~> 0.2.0"},
      {:ash_postgres, "~> 0.38.11"},
      {:postgrex, ">= 0.0.0"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:nimble_parsec, "~> 1.1"},
      {:file_system, "~> 0.2.1 or ~> 0.3"},
      {:uuid, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"}
    ]

  def docs, do: [output: @docs_path]

  def releases,
    do: [
      lyric_screen: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        strip_beams: true,
        path: Path.join(@build_path, "rel"),
        include_erts: true,
        rel_templates_path: Path.join(@src_path, "rel"),
        steps: [&copy_static/1, :assemble],
        runtime_config_path: Path.join(@config_dir_path, "release.exs")
      ]
    ]

  def project,
    do: [
      app: :lyric_screen,
      version: @version,
      elixir: "~> 1.12",
      elixirc_options: [warnings_as_errors: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      config_path: @config_path,
      test_paths: [@test_path],
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      build_path: @build_path,
      preferred_cli_env: preferred_cli_envs(),
      deps_path: @deps_path,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      releases: releases()
    ]

  def application,
    do: [
      mod: {LyricScreen.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]

    defp aliases do
      generated_migrations_path = Path.join(@priv_path, "data/generated_migrations")
      full_generated_migrations_path = Path.join(generated_migrations_path, "repo/migrations")
      resource_snapshots_path = Path.join(@priv_path, "data/resource_snapshots")
      [
        "db.gen.migrations": ["ash_postgres.generate_migrations --snapshot-path #{resource_snapshots_path} --migration-path #{generated_migrations_path}"],
        "rmdir.generated_migrations": ["rmdir #{generated_migrations_path}"],
        "rmdir.resource_snapshots": ["rmdir #{resource_snapshots_path}"],
        "db.gen.migrations.clean": [
          "rmdir.resource_snapshots",
          fn _ -> Mix.Task.reenable("rmdir") end,
          "rmdir.generated_migrations",
          "db.gen.migrations",
        ],
        "db.generated_migrations": ["ecto.migrate --migrations-path #{full_generated_migrations_path}"],
        r: ~w{phx.server},
        "db.drop": ~w{ecto.drop},
        "db.create": ~w{ecto.create},
        "db.migrate": [
          "db.gen.migrations.clean",
          "ecto.migrate",
          fn _ -> Mix.Task.reenable("ecto.migrate") end,
          "db.generated_migrations",
        ],
        "db.seed": ["run #{@priv_path}/data/seed.exs"],
        "db.reset.empty": ~w{db.drop db.create db.migrate},
        "db.reset": ~w{db.reset.empty db.seed},
        "db.check_migration_rollback": [
          "db.create",
          "ecto.load --skip-if-loaded",
          "db.migrate",
          "ecto.rollback --to 20210502154902",
          "db.migrate"
        ],
        "test.db.reset": ~w{db.reset.empty},
        "test.clean": ~w{test.db.reset test},
        ci: [
          "credo --strict -C tests",
          fn _ -> Mix.Task.reenable("credo") end,
          "credo --strict",
          "format --check-formatted",
          "dialyzer",
          "db.check_migration_rollback"
        ]
      ]
    end

  defp elixirc_paths(:test), do: elixirc_paths(nil) ++ [Path.join(@test_path, "support")]
  defp elixirc_paths(_), do: [@src_path]

  def copy_static(r) do
    d = Path.join([Application.app_dir(:lyric_screen), "priv/static"])
    IO.puts("Copying priv to #{Mix.env()} application build: #{d}")
    File.rm_rf!(d)
    File.mkdir_p!(d)
    File.cp_r!(Path.join(@priv_path, "static"), d, fn _, _ -> true end)
    r
  end

  defp preferred_cli_envs() do
    Enum.flat_map(aliases(), fn {key, _tasks} ->
      preferred_cli_env(Atom.to_string(key), key)
    end)
  end

  defp preferred_cli_env("test." <> _rest, key), do: [{key, :test}]
  defp preferred_cli_env(_, _), do: []
end
