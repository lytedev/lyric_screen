defmodule LyricScreen.Web.DisplayController do
  use LyricScreen.Web, :controller

  def show_control_panel(conn, %{"id" => id}) do
    live_render(
      conn,
      LyricScreen.Web.Live.ControlPanel,
      session: %{"display" => id}
    )
  end
end
