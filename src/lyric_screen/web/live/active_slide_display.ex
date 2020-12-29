defmodule LyricScreen.Web.Live.ActiveSlideDisplay do
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

	def handle_info(%{topic: <<"display:", _display_id::binary>>, payload: display}, socket) do
		{:noreply, assign(socket, display: display)}
	end

	def send_display_update(socket) do
		d = socket.assigns.display
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
		{:ok, playlist} = Playlist.load_from_file(playlist_id)
		assign(socket, playlist: playlist)
		|> load_song(Enum.at(playlist.songs, socket.assigns.display.current_song_index))
	end

	def load_song(socket, nil), do: socket
	def load_song(socket, song_key) do
		case Song.load_from_file(song_key) do
			{:ok, song} ->
				mapped_verses =
					song.verses
					|> Enum.reduce([], fn (v, acc) ->
						case v do
							%SongVerse{type: :bare} = sv -> [{"", Enum.join(sv.content, "\n")} | acc]
							%SongVerse{type: :named} = sv -> [{sv.key, Enum.join(sv.content, "\n")} | acc]
							%SongVerse{type: :ref, key: key} = sv ->
								matching_verse =
									song.verses
									|> Enum.find(fn v -> v.key == key && v.type == :named end)
									|> case do
										%SongVerse{} = msv -> msv
										_ -> %SongVerse{type: :bare, key: key, content: [""]}
									end
								[{sv.key, Enum.join(matching_verse.content, "\n")} | acc]
						end
					end)
					|> Enum.reverse()
				slides = [{"@title", song.display_title} | mapped_verses]
				socket
				|> assign(song: song)
				|> assign(slides: slides)
			_ -> socket
		end
	end

	def add_song_to_playlist(socket, song_key) do
		case Playlist.append_song(socket.assigns.playlist, song_key) do
      {:ok, playlist} ->
        socket
        |> assign(playlist: playlist)
        |> set_current_song(Enum.count(socket.assigns.playlist.songs))
			_ -> {:noreply, socket}
		end
	end

  def set_current_song(socket, i \\ nil) do
    i = if i == nil, do: socket.assigns.display.current_song_index, else: i
    num_songs = Enum.count(socket.assigns.playlist.songs)
    {:ok, display} = Display.set_current_song_index(socket.assigns.display, i)
    {:ok, display} = Display.set_current_slide_index(display, 0)
    cond do
      i >= 0 and i < num_songs ->
        {:noreply, socket
          |> assign(display: display)
          |> load_song(Enum.at(socket.assigns.playlist.songs, display.current_song_index))}

      num_songs > 0 and i >= num_songs ->
        Logger.warn("Backing up...")
        set_current_song(socket, i - 1)

      true ->
        {:noreply, assign(socket, display: display, song: nil)}
    end
  end

  def set_current_slide(socket, i \\ nil) do
    i = if i == nil, do: socket.assigns.display.current_slide_index, else: i
    num_slides = Enum.count(socket.assigns.slides)
    {:ok, display} = Display.set_current_slide_index(socket.assigns.display, i)
		{rep, sock} =
			cond do
				i == -1 -> set_current_song(socket, socket.assigns.display.current_song_index - 1)
				i == num_slides -> set_current_song(socket, socket.assigns.display.current_song_index + 1)

				i >= 0 and i < num_slides ->
					{:noreply, socket |> assign(display: display)}

				num_slides > 0 and i >= num_slides ->
					Logger.warn("Backing up...")
					set_current_song(socket, i - 1)

				true ->
					{:noreply, assign(socket, display: display, song: nil)}
			end
		send_display_update(sock)
		{rep, sock}
  end

	def handle_event("remove_song_at", %{"index" => index}, socket) do
		case Playlist.remove_song_at(socket.assigns.playlist, String.to_integer(index)) do
      {:ok, playlist} ->
        socket
        |> assign(playlist: playlist)
        |> set_current_song()
			_ -> {:noreply, socket}
		end
	end

	def handle_event("set_current_song", %{"index" => index}, socket) do
    i = String.to_integer(index)
    set_current_song(socket, i)
  end

	def handle_event("set_current_slide", %{"index" => index}, socket) do
    i = String.to_integer(index)
    set_current_slide(socket, i)
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
  def handle_event("add_song", _, socket) do
		{:noreply, assign(socket, adding_song?: true)}
	end

	def handle_event("nav", _path, socket), do: {:noreply, socket}
	def handle_event("hide_sidebar", _path, socket), do: {:noreply, assign(socket, show_sidebar?: false)}
	def handle_event("show_sidebar", _path, socket), do: {:noreply, assign(socket, show_sidebar?: true)}
end
