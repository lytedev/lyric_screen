defmodule LyricScreen.Web.ChatChannel do
  @moduledoc false

  use Phoenix.Channel

  def join("event_bus:" <> _chat_id, _message, socket) do
    {:ok, socket}
  end
end
