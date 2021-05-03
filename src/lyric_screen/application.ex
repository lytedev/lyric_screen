defmodule LyricScreen.Application do
  @moduledoc false

  use Application
  alias LyricScreen.Web

  def start(_type, _args) do
    children = [
      LyricScreen.Repo,
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
