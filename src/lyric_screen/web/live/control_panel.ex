defmodule LyricScreen.Web.Live.ControlPanel do
	@moduledoc false

	use Phoenix.LiveView
	use Phoenix.HTML
	alias LyricScreen.{Playlist, Display}
	require Logger

	def render(assigns) do
		~L"""
		<div>
			<h1><code><%= @playlist.key %></code> Playlist</h2>
			<ul>
				<%= for {s, i} <- Enum.with_index(songs(@playlist)) do %>
					<li class="<%= if current_song?(@display, i) do %>active<% end %>">
						<a href="#" phx-click="set_current_song" phx-value-index="<%= i %>"><%= s %></a>
						<a href="#" phx-click="remove_song_at" phx-value-index="<%= i %>">-</a>
					</li>
				<% end %>
			</ul>
		</div>
		"""
	end

	defp songs(playlist), do: playlist.songs
	defp current_song?(display, index), do: display.current_song_index == index

	def mount(_params, session, socket) do
		Logger.warn(session)
		{:ok, load_display(socket, session["display"])}
	end

	def load_playlist(socket, playlist_id) do
		{:ok, playlist} = Playlist.load_from_file(playlist_id)
		assign(socket, playlist: playlist)
	end

	def load_display(socket, display_id) do
		{:ok, display} = Display.load_from_file(display_id)
		socket
		|> assign(display: display)
		|> load_playlist(display.playlist)
	end

	def handle_event("remove_song_at", %{"index" => index}, socket) do
		case Playlist.remove_song_at(socket.assigns.playlist, String.to_integer(index)) do
			{:ok, playlist} -> {:noreply, assign(socket, playlist: playlist)}
			_ -> {:noreply, socket}
		end
	end

	def handle_event("set_current_song", %{"index" => index}, socket) do
		{:ok, display} = Display.set_current_song_index(socket.assigns.display, String.to_integer(index))
		{:noreply, assign(socket, display: display)}
	end

	def handle_event("nav", _path, socket) do
		{:noreply, socket}
	end
end
