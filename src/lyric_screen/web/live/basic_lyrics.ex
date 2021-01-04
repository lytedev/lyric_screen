defmodule LyricScreen.Web.Live.BasicLyrics do
	@moduledoc false

	use Phoenix.HTML
	use Phoenix.LiveView
	alias LyricScreen.{Display, Web.Endpoint}
	require Logger

	def mount(_params, session, socket), do: {:ok, load_display(socket, session["display"])}

	def load_display(socket, display_id) do
		Logger.debug("Loading Display: #{display_id}")
		case Display.load_from_file(display_id) do
			{:ok, display} ->
				Phoenix.PubSub.subscribe(LyricScreen.PubSub, "display:#{display_id}")
				socket
				|> assign(display: display)
				|> set_slide_contents()
		end
	end

	def set_slide_contents(socket) do
		case Display.current_slide(socket.assigns.display) do
			{:ok, {_title, contents}} -> assign(socket, current_slide_contents: contents)
			_ -> assign(socket, current_slide_contents: "")
		end
	end

  @sync_all_keys [:display]
	def send_sync_all(socket) do
    payload = Map.take(socket.assigns, @sync_all_keys)
		Logger.debug("Sending Sync All: #{inspect(payload, pretty: true)}")
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "sync_all", payload)
		socket
	end

	def handle_info(%{event: "sync_all", topic: <<"display:", _display_id::binary>>, payload: assigns} = ev, socket) do
		Logger.debug(inspect(ev))
		Logger.debug("Received Sync All")
		{:noreply, socket |> assign(Map.take(assigns, @sync_all_keys)) |> set_slide_contents()}
	end
end
