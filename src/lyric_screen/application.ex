defmodule LyricScreen.Application do
	@moduledoc false

	use Application

	alias LyricScreen.{Web, Playlist, Display}

	def start(_type, _args) do
		[:displays_dir, :playlists_dir, :songs_dir]
		|> Enum.each(&(:ok = File.mkdir_p(Application.get_env(:lyric_screen, &1))))

		if !Playlist.File.exists?("default"), do: Playlist.save_to_file(%Playlist{key: "default"})
		if !Display.File.exists?("default"), do: Display.save_to_file(%Display{key: "default"})

		children = [
			Web.Telemetry,
			{Phoenix.PubSub, name: LyricScreen.PubSub},
			Web.Endpoint
		]

		opts = [strategy: :one_for_one, name: LyricScreen.Supervisor]
		Supervisor.start_link(children, opts)
	end

	def config_change(changed, _new, removed) do
		Web.Endpoint.config_change(changed, removed)
		:ok
	end
end
