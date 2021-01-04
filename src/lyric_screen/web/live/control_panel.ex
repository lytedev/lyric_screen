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
    {:ok,
      socket
			|> load_all_songs()
			|> assign(
				in_modal?: false,
				adding_song?: false,
				search_test: "",
				show_sidebar?: true,
				new_song_allowed?: false,
				add_song_allowed?: false
			)
      |> load_display(session["display"])
    }
	end

	def current_song(socket), do: Display.current_song(socket.assigns.display)
	def current_playlist(socket), do: Display.playlist(socket.assigns.display)
	def show_add_song_form(socket), do: assign(socket, adding_song?: true, in_modal?: true)

	def load_display(socket, display_id) do
		Logger.debug("Loading Display: #{display_id}")
		# TODO: check if currently subscribed to a display
		case Display.load_from_file(display_id) do
			{:ok, display} ->
				Phoenix.PubSub.subscribe(LyricScreen.PubSub, "display:#{display_id}")
				socket
				|> assign(display: display)
				|> load_playlist()

			_ -> socket
		end
	end

	def load_all_songs(socket) do
    {:ok, songs} = Song.File.ls()
		assign(socket, suggested_songs: songs)
	end

	def load_playlist(socket) do
		Logger.debug("Loading Current Playlist")
		case current_playlist(socket) do
			{:ok, playlist} ->
				socket
				|> assign(playlist: playlist)
				|> load_song()

			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def load_song(socket) do
		Logger.debug("Loading Current Song")
		case current_song(socket) do
			{:ok, song} ->
				socket
				|> assign(slides: Song.map(song))
			err ->
				Logger.warn(inspect(err))
				assign(socket, slides: [])
		end
	end

	def add_song_to_playlist(socket, song_key) do
		case Playlist.append_song(socket.assigns.playlist, song_key) do
      {:ok, playlist} ->
        socket
        |> assign(playlist: playlist)
        |> set_current_song_and_load(Enum.count(socket.assigns.playlist.songs))
			_ -> socket
		end
	end

  def set_current_song_and_load(socket, i \\ nil) do
    {:ok, display} = Display.set_current_song_index(socket.assigns.display, i)
		socket
		|> assign(display: display)
		|> load_song()
  end

  def set_current_slide(socket, i \\ nil) do
    {:ok, display} = Display.set_current_slide_index(socket.assigns.display, i)
		assign(socket, display: display)
  end

	def reorder_song(socket, old_at, new_at) do
		playlist = socket.assigns.playlist
		old_songs = playlist.songs
		{song, rest} = List.pop_at(old_songs, old_at)
		case Playlist.set_songs(playlist, List.insert_at(rest, new_at, song)) do
			{:ok, playlist} ->
				socket
				|> assign(playlist: playlist)
				|> set_current_song_and_load(new_at)
			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def reorder_slide(socket, old_at, new_at) do
		case current_song(socket) do
			{:ok, song} ->
				{verse, rest} = List.pop_at(song.verses, old_at)
				set_current_song_verses(socket, List.insert_at(rest, new_at, verse))
			err ->
				Logger.error(inspect(err))
				socket
		end
	end

	def set_current_song_verses(socket, verses) do
		{:ok, song} = current_song(socket)
		case Song.set_verses(song, verses) do
			{:ok, _song} -> load_song(socket)
			err ->
				Logger.error(inspect(err))
				socket
		end
	rescue
		err ->
			Logger.error(inspect(err))
			socket
	end

	def edit_slide(socket, at, %SongVerse{} = sv) do
		{:ok, song} = current_song(socket)
		set_current_song_verses(socket, List.replace_at(song.verses, at, sv))
	rescue
		err ->
			Logger.error(inspect(err))
			socket
	end

	def send_playlist_sync(socket, playlist \\ nil) do
		Logger.debug("Sending Playlist Sync")
		d = playlist || socket.assigns.playlist
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "playlist_sync", d)
		socket
	end

	def send_song_sync(socket) do
		Logger.debug("Sending Song Sync")
		d = %{slides: socket.assigns.slides, display: socket.assigns.display}
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "song_sync", d)
		socket
	end

	def send_display_sync(socket, display \\ nil) do
		Logger.debug("Sending Display Sync")
		d = display || socket.assigns.display
		Endpoint.broadcast_from(self(), "display:#{d.key}", "display_sync", d)
		socket
	end

  @sync_all_keys [:display, :slides, :playlist]
	def send_sync_all(socket) do
    payload = Map.take(socket.assigns, @sync_all_keys)
		Logger.debug("Sending Sync All: #{inspect(payload, pretty: true)}")
		Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.key}", "sync_all", payload)
		socket
	end

	def handle_info(%{event: "sync_all", topic: <<"display:", _display_id::binary>>, payload: assigns} = ev, socket) do
		Logger.debug(inspect(ev))
		Logger.debug("Received Sync All")
		{:noreply, assign(socket, Map.take(assigns, @sync_all_keys))}
	end

  defp simple_sync_event(socket), do: {:noreply, send_sync_all(socket)}

	def handle_event("remove_song_at", %{"index" => index}, socket) do
    {:ok, playlist} = Playlist.remove_song_at(socket.assigns.playlist, String.to_integer(index))
    socket
    |> assign(playlist: playlist)
    |> set_current_song_and_load()
    |> simple_sync_event()
  rescue err ->
    Logger.error(inspect(err))
    simple_sync_event(socket)
	end

	def handle_event("set_current_song", %{"index" => index}, socket) do
    i = String.to_integer(index)
		cond do
			i == socket.assigns.display.current_song_index -> {:noreply, socket}
			true ->
				{:noreply,
					socket
					|> set_current_slide(0)
					|> set_current_song_and_load(i)
					|> send_sync_all()
				}
		end
  end

  def handle_event("prev_song", _, socket) do
    {:noreply,
      socket
      |> set_current_slide(0)
      |> set_current_song_and_load(socket.assigns.display.current_song_index - 1)
      |> send_sync_all()
    }
  end

  def handle_event("next_song", _, socket) do
    {:noreply,
      socket
      |> set_current_slide(0)
      |> set_current_song_and_load(socket.assigns.display.current_song_index + 1)
      |> send_sync_all()
    }
  end

  def handle_event("prev_slide", _, socket) do
    {:noreply,
      socket
      |> set_current_slide(socket.assigns.display.current_slide_index - 1)
      |> set_current_song_and_load()
      |> send_sync_all()
    }
  end

  def handle_event("next_slide", _, socket) do
    {:noreply,
      socket
      |> set_current_slide(socket.assigns.display.current_slide_index + 1)
      |> set_current_song_and_load()
      |> send_sync_all()
    }
  end

	def handle_event("set_current_slide", %{"index" => index}, socket) do
    i = String.to_integer(index)
		cond do
			i == socket.assigns.display.current_slide_index -> {:noreply, socket}
			true ->
				{:noreply,
					socket
					|> set_current_slide(i)
					|> send_sync_all()
				}
		end
  end

  def handle_event("suggest_song", %{"song" => search_term}, socket) do
		# search is handled by the datalist containing all songs.
    # TODO: word boundary searching?
		# TODO: reload song list when file system changes?
    # suggested_songs = Enum.filter(songs, &(String.contains?(String.downcase(&1), String.downcase(search_term))))
    #{:noreply, assign(socket, suggested_songs: suggested_songs)}
		exists? = Song.File.exists?(search_term)
		new_song_allowed? = search_term != "" && !exists?
		add_song_allowed? = search_term != "" && exists?
		Logger.debug(inspect({search_term, exists?, new_song_allowed?, add_song_allowed?}))
		{:noreply,
			socket
			|> assign(
				new_song_allowed?: new_song_allowed?,
				add_song_allowed?: add_song_allowed?
			)
		}
  end

	def handle_event("cancel_add_song", _, socket) do
		{:noreply, assign(socket, adding_song?: false, in_modal?: false)}
	end

  def handle_event("add_song", %{"song" => song_name, "add_song_type" => "newsong"}, socket) do
		{:ok, song} = Song.new(song_name)
    {:ok, playlist} = Playlist.append_song(socket.assigns.playlist, song)
    socket
    |> assign(playlist: playlist, adding_song?: false, in_modal?: false)
		|> set_current_slide(0)
    |> set_current_song_and_load(Enum.count(playlist.songs))
    |> simple_sync_event()
  rescue err ->
    Logger.error(inspect(err))
    simple_sync_event(socket)
		{:noreply, socket}
	end
  def handle_event("add_song", %{"song" => song} = arg, socket) do
		Logger.warn(inspect(arg))
		{:noreply,
			socket
			|> assign(adding_song?: false, in_modal?: false)
			|> add_song_to_playlist(song)
			|> send_sync_all()
		}
	end
	def handle_event("add_song", _, socket) do
		{:noreply,
			socket
			|> show_add_song_form()
		}
	end

	# user didn't actually move it -- noop
	def handle_event("dropped", %{"new_at" => at, "old_at" => at, "type" => type}, socket), do: {:noreply, socket}
	def handle_event("dropped", %{"new_at" => new_at, "old_at" => old_at, "type" => type}, socket) do
		case type do
			"slides" ->
				{:noreply,
					socket
					|> reorder_slide(old_at, new_at)
					|> send_sync_all()
				}
			"songlist" ->
				{:noreply,
					socket
					|> reorder_song(old_at, new_at)
					|> send_sync_all()
				}
		end
	end

	def handle_event("nav", _path, socket), do: {:noreply, socket}
	def handle_event("hide_sidebar", _path, socket), do: {:noreply, assign(socket, show_sidebar?: false)}
	def handle_event("show_sidebar", _path, socket), do: {:noreply, assign(socket, show_sidebar?: true)}

  def handle_event("key", _, %{assigns: %{in_modal?: true}} = socket), do: {:noreply, socket}

  def handle_event("key", %{"key" => "Escape"}, %{assigns: %{adding_song?: true}} = socket), do: handle_event("cancel_add_song", %{}, socket)

  def handle_event("key", %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowUp"}, socket), do: handle_event("prev_song", %{}, socket)
  def handle_event("key", %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowLeft"}, socket), do: handle_event("prev_song", %{}, socket)
  def handle_event("key", %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowRight"}, socket), do: handle_event("next_song", %{}, socket)
  def handle_event("key", %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowDown"}, socket), do: handle_event("next_song", %{}, socket)

  def handle_event("key", %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowUp"}, socket), do: handle_event("prev_slide", %{}, socket)
  def handle_event("key", %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowLeft"}, socket), do: handle_event("prev_slide", %{}, socket)
  def handle_event("key", %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowRight"}, socket), do: handle_event("next_slide", %{}, socket)
  def handle_event("key", %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowDown"}, socket), do: handle_event("next_slide", %{}, socket)

  def handle_event("key", k, socket) do
    Logger.debug("Key Event: #{inspect(k)}")
    {:noreply, socket}
  end
end
