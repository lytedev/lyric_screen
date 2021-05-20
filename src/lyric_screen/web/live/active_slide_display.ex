defmodule LyricScreen.Web.Live.ActiveSlideDisplay do
  @moduledoc false

  use Phoenix.HTML
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
