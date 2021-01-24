defmodule LyricScreen.Web.Live.BasicLyrics do
	@moduledoc false

	@transition_time_ms 5000

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
				|> assign(display: display, previous_slide_contents: "", transitioning?: false)
				|> set_slide_contents()
		end
	end

	defp assign_previous_slide_contents(socket) do
		assign(socket, previous_slide_contents: Map.get(socket.assigns, :current_slide_contents, ""))
	end

	def set_slide_contents(socket) do
		socket
		|> assign_previous_slide_contents()
		|> do_set_slide_contents()
		|> maybe_transition()
	end

	defp do_set_slide_contents(%{assigns: %{display: %{hidden?: true}}} = socket) do
		assign(socket, current_slide_contents: "")
	end

	defp do_set_slide_contents(%{assigns: %{display: %{frozen?: true, frozen_song: song_index, frozen_slide: slide_index} = display}} = socket) do
		case Display.slide_at(display, song_index, slide_index) do
			{:ok, {_title, content}} -> assign(socket, current_slide_contents: content)
			_err -> assign(socket, current_slide_contents: "")
		end
	end

	defp do_set_slide_contents(%{assigns: %{display: display}} = socket) do
		case Display.current_slide(display) do
			{:error, _err} -> assign(socket, current_slide_contents: "")
			{_title, contents} -> assign(socket, current_slide_contents: contents)
		end
	end

  @sync_all_keys [:display]
	def send_sync_all(socket) do
    payload = Map.take(socket.assigns, @sync_all_keys)
		Logger.debug("Sending Sync All: #{inspect(payload, pretty: true)}")
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "sync_all", payload)
		socket
	end

	defp maybe_transition(%{assigns: %{current_slide_contents: cur, previous_slide_contents: prev}} = socket) do
		if cur == prev do
			socket
		else
			do_transition(socket)
		end
	end

	defp do_transition(socket) do
		# if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
		# def handle_info(:tick, socket) do
		Logger.debug("Transitioning...")
		if connected?(socket) do
			Process.send_after(self(), :finish_transition, @transition_time_ms)
		end
		assign(socket, transitioning?: true)
	end

	def handle_info(:finish_transition, socket) do
		Logger.debug("Finish Transition")
		{:noreply, assign(socket, transitioning?: false)}
	end

	def handle_info(%{event: "sync_all", topic: <<"display:", _display_id::binary>>, payload: assigns} = ev, socket) do
		Logger.debug(inspect(ev))
		Logger.debug("Received Sync All")
		{:noreply, socket |> assign(Map.take(assigns, @sync_all_keys)) |> set_slide_contents()}
	end

	defp transition_time_ms(), do: @transition_time_ms
end
