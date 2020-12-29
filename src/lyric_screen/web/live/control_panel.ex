defmodule LyricScreen.Web.Live.ControlPanel do
	@moduledoc false

	use Phoenix.HTML
	use Phoenix.LiveView
	alias LyricScreen.{Web.Endpoint, Display, Playlist, Song, SongVerse}
	require Logger

	defp songs(playlist), do: playlist.songs
	defp current_song?(display, index), do: display.current_song_index == index
	defp current_slide?(display, index), do: display.current_slide_index == index

	def mount(_params, session, socket) do
		Logger.warn(session)
    {:ok, songs} = Song.File.ls()
    {:ok,
      socket
      |> assign(adding_song?: false, search_test: "", suggested_songs: songs, show_sidebar?: true)
      |> load_display(session["display"])
    }
	end

	def handle_info(%{event: "song_sync", topic: <<"display:", _display_id::binary>>, payload: %{song: song, slides: slides, display: display}} = ev, socket) do
		Logger.debug(inspect(ev))
		Logger.debug("Received Song Sync")
		{:noreply, assign(socket, song: song, slides: slides, display: display)}
	end

	def handle_info(%{event: "playlist_sync", topic: <<"display:", _display_id::binary>>, payload: playlist} = ev, socket) do
		Logger.debug(inspect(ev))
		Logger.debug("Received Playlist Sync")
		{:noreply, assign(socket, playlist: playlist)}
	end

	def handle_info(%{event: "display_sync", topic: <<"display:", _display_id::binary>>, payload: display} = ev, socket) do
		Logger.debug(inspect(ev))
		Logger.debug("Received Display Sync")
		{:noreply, assign(socket, display: display)}
	end

	def send_playlist_sync(socket, playlist \\ nil) do
		Logger.debug("Sending Song Sync")
		d = playlist || socket.assigns.playlist
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "playlist_sync", d)
	end

	def send_song_sync(socket) do
		Logger.debug("Sending Song Sync")
		d = %{song: socket.assigns.song, slides: socket.assigns.slides, display: socket.assigns.display}
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "song_sync", d)
	end

	def send_display_sync(socket, display \\ nil) do
		Logger.debug("Sending Display Sync")
		d = display || socket.assigns.display
		Endpoint.broadcast_from(self(), "display:#{d.key}", "display_sync", d)
	end

	def load_display(socket, display_id) do
		case Display.load_from_file(display_id) do
			{:ok, display} ->
				Phoenix.PubSub.subscribe(LyricScreen.PubSub, "display:#{display_id}")
				socket
				|> assign(display: display)
				|> load_playlist(display.playlist)

			_ -> socket
		end
	end

	def load_playlist(socket, playlist_id) do
		Logger.info(playlist_id)
		case Playlist.load_from_file(playlist_id) do
			{:ok, playlist} ->
				socket
				|> assign(playlist: playlist)
				|> load_song()

			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def load_song(socket, song_id \\ nil) do
		Logger.debug(inspect({socket.assigns.playlist, song_id}))
		case Playlist.song_at(socket.assigns.playlist, song_id || socket.assigns.display.current_song_index) do
			{:ok, song} ->
				socket
				|> assign(song: song)
				|> assign(slides: Song.map(song))
			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def add_song_to_playlist(socket, song_key) do
		case Playlist.append_song(socket.assigns.playlist, song_key) do
      {:ok, playlist} ->
				{:noreply,
					socket
					|> assign(playlist: playlist)
					|> set_current_song(Enum.count(socket.assigns.playlist.songs))
				}
			_ -> {:noreply, socket}
		end
	end

  def set_current_song(socket, i \\ nil) do
    {:ok, display} = Display.set_current_song_index(socket.assigns.display, i)
		socket = socket |> assign(display: display) |> load_song()
		send_song_sync(socket)
		socket
  end

  def set_current_slide(socket, i \\ nil) do
    {:ok, display} = Display.set_current_slide_index(socket.assigns.display, i)
		send_display_sync(socket, display)
		assign(socket, display: display)
  end

	def show_add_song_form(socket), do: {:noreply, assign(socket, adding_song?: true)}

	def reorder_song(socket, old_at, new_at) do
		playlist = socket.assigns.playlist
		old_songs = playlist.songs
		{song, rest} = List.pop_at(old_songs, old_at)
		songs = List.insert_at(rest, new_at, song)
		case Playlist.set_songs(playlist, songs) do
			{:ok, playlist} ->
				socket =
					socket
					|> assign(playlist: playlist)
					|> set_current_song(new_at)
				send_playlist_sync(socket)
				send_display_sync(socket)
				socket
			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def reorder_slide(socket, old_at, new_at) do
		song = socket.assigns.song
		old_verses = song.verses
		{verse, rest} = List.pop_at(old_verses, old_at)
		verses = List.insert_at(rest, new_at, verse)
		case Song.set_verses(song, verses) do
			{:ok, song} ->
				socket =
					socket
					|> assign(song: song, slides: Song.map(song))
					|> set_current_slide(new_at + 1)
				send_song_sync(socket)
				socket
			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def handle_event("remove_song_at", %{"index" => index}, socket) do
		case Playlist.remove_song_at(socket.assigns.playlist, String.to_integer(index)) do
      {:ok, playlist} ->
				send_playlist_sync(socket, playlist)
				{:noreply,
					socket
					|> assign(playlist: playlist)
					|> set_current_song()
				}
			_ -> {:noreply, socket}
		end
	end

	def handle_event("set_current_song", %{"index" => index}, socket) do
    i = String.to_integer(index)
		{:noreply, set_current_song(socket, i)}
  end

	def handle_event("set_current_slide", %{"index" => index}, socket) do
    i = String.to_integer(index)
		{:noreply, set_current_slide(socket, i)}
  end

  def handle_event("suggest_song", %{"song" => _search_term}, socket) do
		# NOTE: This is now handled by the datalist containing all songs.
    # {:ok, songs} = Song.File.ls()
    # TODO: word boundary searching
		# TODO: reload song list when file system changes?
    # suggested_songs = Enum.filter(songs, &(String.contains?(String.downcase(&1), String.downcase(search_term))))
    #{:noreply, assign(socket, suggested_songs: suggested_songs)}
    {:noreply, socket}
  end

	def handle_event("cancel_add_song", _, socket) do
		{:noreply, assign(socket, adding_song?: false)}
	end

  def handle_event("add_song", %{"song" => song}, socket) do
		socket
		|> assign(adding_song?: false)
		|> add_song_to_playlist(song)
	end
  def handle_event("add_song", _, socket), do: show_add_song_form(socket)

	def handle_event("dropped", %{"new_at" => new_at, "old_at" => old_at, "type" => type}, socket) do
		case type do
			"slides" -> {:noreply, reorder_slide(socket, old_at, new_at)}
			"songlist" -> {:noreply, reorder_song(socket, old_at, new_at)}
		end
	end

	def handle_event("nav", _path, socket), do: {:noreply, socket}
	def handle_event("hide_sidebar", _path, socket), do: {:noreply, assign(socket, show_sidebar?: false)}
	def handle_event("show_sidebar", _path, socket), do: {:noreply, assign(socket, show_sidebar?: true)}
end
