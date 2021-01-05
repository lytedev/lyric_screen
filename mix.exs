defmodule LyricScreen.MixProject do
	use Mix.Project

	@version "0.4.5"

	@src_path "src"
	@priv_path Path.join(@src_path, "priv")
	@config_dir_path Path.join(@src_path, "config")
	@config_path Path.join(@config_dir_path, "config.exs")
	@test_path Path.join(@src_path, "test")
	@build_path "build"
	@deps_path Path.join(@build_path, "deps")
	@docs_path Path.join(@build_path, "docs")

	defp deps, do: [
		{:credo, "~> 1.5", only: [:dev, :test], runtime: false},
		{:dialyxir, "~> 1.0", only: [:dev], runtime: false},
		{:phoenix, "~> 1.5.6"},
		{:phoenix_html, "~> 2.11"},
		{:phoenix_live_view, "~> 0.15.1"},
		{:floki, ">= 0.27.0", only: :test},
		{:phoenix_live_reload, "~> 1.2", only: :dev},
		{:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
		{:telemetry_metrics, "~> 0.4"},
		{:telemetry_poller, "~> 0.4"},
		{:gettext, "~> 0.11"},
		{:jason, "~> 1.0"},
		{:nimble_parsec, "~> 1.1"},
		{:file_system, "~> 0.2.1 or ~> 0.3"},
		{:plug_cowboy, "~> 2.0"}
	]

	def docs, do: [output: @docs_path]

	def releases, do: [
		lyric_screen: [
			include_executables_for: [:unix],
			applications: [runtime_tools: :permanent],
			strip_beams: true,
			path: Path.join(@build_path, "rel"),
			include_erts: true,
			rel_templates_path: Path.join(@src_path, "rel"),
			steps: [&copy_static/1, :assemble],
			runtime_config_path: Path.join(@config_dir_path, "release.exs"),
		],
	]

	def project, do: [
		app: :lyric_screen,
		version: @version,
		elixir: "~> 1.7",
		elixirc_paths: elixirc_paths(Mix.env()),
		config_path: @config_path,
		test_paths: [@test_path],
		compilers: [:phoenix, :gettext] ++ Mix.compilers(),
		start_permanent: Mix.env() == :prod,
		build_path: @build_path,
		deps_path: @deps_path,
		deps: deps(),
		docs: docs(),
		releases: releases(),
	]

	def application, do: [
		mod: {LyricScreen.Application, []},
		extra_applications: [:logger, :runtime_tools, :os_mon]
	]

	defp elixirc_paths(:test), do: elixirc_paths(nil) ++ [Path.join(@test_path, "support")]
	defp elixirc_paths(_), do: [@src_path]

	def copy_static(r) do
		d = Path.join([Application.app_dir(:lyric_screen), "priv/static"])
		IO.puts("Copying priv to #{Mix.env()} application build: #{d}")
		File.rm_rf!(d)
		File.mkdir_p!(d)
		File.cp_r!(Path.join(@priv_path, "static"), d, fn (_, _) -> true end)
		r
	end
end
