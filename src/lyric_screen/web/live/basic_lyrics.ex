defmodule LyricScreen.Web.Live.BasicLyrics do
  @moduledoc false

  @transition_time_ms 5000

  use Phoenix.HTML
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def transition_time_ms(), do: @transition_time_ms
end
