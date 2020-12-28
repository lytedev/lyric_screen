defmodule LyricScreen.Application do
	@moduledoc false

	use Application

	def start(_type, _args) do
		children = [
			LyricScreen.Web.Telemetry,
			{Phoenix.PubSub, name: LyricScreen.PubSub},
			LyricScreen.Web.Endpoint
		]

		opts = [strategy: :one_for_one, name: LyricScreen.Supervisor]
		Supervisor.start_link(children, opts)
	end

	def config_change(changed, _new, removed) do
		LyricScreen.Web.Endpoint.config_change(changed, removed)
		:ok
	end
end
