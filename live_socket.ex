defmodule LyricScreen.Web.LiveSocket do
	@moduledoc """
	The LiveView socket for Phoenix endpoints.
	"""

	use Phoenix.Socket

	channel "event_bus:*", LyricScreen.Web.ChatChannel
  channel "lv:*", Phoenix.LiveView.Channel

  defstruct id: nil,
            endpoint: nil,
            parent_pid: nil,
            assigns: %{},
            changed: %{},
            fingerprints: {nil, %{}},
            private: %{},
            stopped: nil,
            connected?: false

  @doc """
  Connects the Phoenix.Socket for a LiveView client.
  """
  @impl Phoenix.Socket
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @doc """
  Identifies the Phoenix.Socket for a LiveView client.
  """
  @impl Phoenix.Socket
  def id(_socket), do: nil
end
