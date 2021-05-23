defmodule LyricScreen.Web.Live.ControlPanel do
  @moduledoc false

  use Phoenix.HTML
  use Phoenix.LiveView
  require Logger

  def mount(_params, session, socket) do
    Logger.warn(session)

    {
      :ok,
      socket
      # |> load_all_songs()
      # |> close_all_modals()
      # |> assign(search_test: "", show_sidebar?: true)
      # |> load_display(session["display"])}
    }
  end

  # def close_all_modals(socket) do
  #   assign(socket,
  #     in_modal?: false,
  #     adding_song?: false,
  #     adding_slide?: false,
  #     editing_slide?: false,
  #     new_song_allowed?: false,
  #     add_song_allowed?: false,
  #     add_slide_type: "bare",
  #     edit_slide_at: nil,
  #     edit_slide_content: "",
  #     edit_slide_id: "",
  #     add_slide_valid?: false
  #   )
  # end

  # def terminate(reason, socket) do
  #   Logger.info("Control Panel LiveView Terminated: #{inspect(socket)}}#{inspect(reason)}")
  #   :ok
  # end

  # def current_song(socket), do: Display.current_song(socket.assigns.display)
  # def current_playlist(socket), do: Display.playlist(socket.assigns.display)

  # # TODO: add slide events need to have a song bound to them to prevent adding to a song after it changes and we add to the wrong song
  # def show_add_slide_form(socket),
  #   do: assign(socket, adding_slide?: true, in_modal?: true, add_slide_type: "bare")

  # def set_add_slide_type(socket, type),
  #   do: assign(socket, add_slide_type: type) |> check_add_slide_valid()

  # def show_add_song_form(socket), do: assign(socket, adding_song?: true, in_modal?: true)

  # def check_add_slide_valid(socket) do
  #   Logger.warn(inspect(socket.assigns.add_slide_type))

  #   if socket.assigns.add_slide_type == "repeat" do
  #     assign(socket, add_slide_valid?: true)
  #   else
  #     assign(socket, add_slide_valid?: false)
  #   end
  # end

  # def load_display(socket, display_id) do
  #   Logger.debug("Loading Display: #{display_id}")
  #   # TODO: check if currently subscribed to a display
  #   case Display.load_from_file(display_id) do
  #     {:ok, display} ->
  #       Phoenix.PubSub.subscribe(LyricScreen.PubSub, "display:#{display_id}")

  #       socket
  #       |> assign(display: display)
  #       |> load_playlist()

  #     _ ->
  #       socket
  #   end
  # end

  # def load_all_songs(socket) do
  #   {:ok, songs} = Song.File.ls()
  #   assign(socket, suggested_songs: songs)
  # end

  # def load_playlist(socket) do
  #   Logger.debug("Loading Current Playlist")

  #   case current_playlist(socket) do
  #     {:ok, playlist} ->
  #       socket
  #       |> assign(playlist: playlist)
  #       |> load_song()

  #     err ->
  #       Logger.error(inspect(err))
  #       socket
  #   end end

  # def load_song(socket) do
  #   Logger.debug("Loading Current Song")

  #   case current_song(socket) do
  #     {:ok, song} ->
  #       socket
  #       |> assign(slides: Song.map(song))

  #     err ->
  #       Logger.warn(inspect(err))
  #       assign(socket, slides: [])
  #   end
  # end

  # def add_song_to_playlist(socket, song_id) do
  #   case Playlist.append_song(socket.assigns.playlist, song_id) do
  #     {:ok, playlist} ->
  #       socket
  #       |> assign(playlist: playlist)
  #       |> set_current_song_and_load(Enum.count(socket.assigns.playlist.songs))

  #     _ ->
  #       socket
  #   end
  # end

  # def set_current_song_and_load(socket, i \\ nil) do
  #   {:ok, display} = Display.set_current_song_index(socket.assigns.display, i)

  #   socket
  #   |> assign(display: display)
  #   |> load_song()
  # end

  # def set_current_slide(socket, i \\ nil) do
  #   {:ok, display} = Display.set_current_slide_index(socket.assigns.display, i)
  #   assign(socket, display: display)
  # end

  # def reorder_song(socket, old_at, new_at) do
  #   playlist = socket.assigns.playlist
  #   old_songs = playlist.songs
  #   {song, rest} = List.pop_at(old_songs, old_at)

  #   case Playlist.set_songs(playlist, List.insert_at(rest, new_at, song)) do
  #     {:ok, playlist} ->
  #       socket
  #       |> assign(playlist: playlist)
  #       |> set_current_song_and_load(new_at)

  #     err ->
  #       Logger.error(inspect(err))
  #       socket
  #   end
  # end

  # def reorder_slide(socket, old_at, new_at) do
  #   Logger.info("Reordering slides: #{inspect(socket)} #{old_at} -> #{new_at}")

  #   case current_song(socket) do
  #     {:ok, song} ->
  #       {verse, rest} = List.pop_at(song.verses, old_at)
  #       set_current_song_verses(socket, List.insert_at(rest, new_at, verse))

  #     err ->
  #       Logger.error(inspect(err))
  #       socket
  #   end
  # end

  # def set_current_song_verses(socket, verses) do
  #   {:ok, song} = current_song(socket)

  #   case Song.set_verses(song, verses) do
  #     {:ok, _song} ->
  #       load_song(socket)

  #     err ->
  #       Logger.error(inspect(err))
  #       socket
  #   end
  # rescue
  #   err ->
  #     Logger.error(inspect(err))
  #     socket
  # end

  # def edit_slide(socket, at, %SongVerse{} = sv) do
  #   {:ok, song} = current_song(socket)
  #   set_current_song_verses(socket, List.replace_at(song.verses, at, sv))
  # rescue
  #   err ->
  #     Logger.error(inspect(err))
  #     socket
  # end

  # def append_slide(socket, %SongVerse{} = sv) do
  #   {:ok, song} = Display.current_song(socket.assigns.display)
  #   set_current_song_verses(socket, song.verses ++ [sv])
  # end

  # defp do_append_slide(socket, %SongVerse{} = sv) do
  #   socket
  #   |> append_slide(sv)
  #   |> close_all_modals()
  #   |> simple_sync_event()
  # end

  # def send_playlist_sync(socket, playlist \\ nil) do
  #   Logger.debug("Sending Playlist Sync")
  #   d = playlist || socket.assigns.playlist
  #   Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.id}", "playlist_sync", d)
  #   socket
  # end

  # def send_song_sync(socket) do
  #   Logger.debug("Sending Song Sync")
  #   d = %{slides: socket.assigns.slides, display: socket.assigns.display}
  #   Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.id}", "song_sync", d)
  #   socket
  # end

  # def send_display_sync(socket, display \\ nil) do
  #   Logger.debug("Sending Display Sync")
  #   d = display || socket.assigns.display
  #   Endpoint.broadcast_from(self(), "display:#{d.id}", "display_sync", d)
  #   socket
  # end

  # @sync_all_keys [:display, :slides, :playlist]
  # def send_sync_all(socket) do
  #   payload = Map.take(socket.assigns, @sync_all_keys)
  #   Logger.debug("Sending Sync All: #{inspect(payload, pretty: true)}")
  #   Endpoint.broadcast_from(self(), "display:#{socket.assigns.display.id}", "sync_all", payload)
  #   socket
  # end

  # def handle_info(
  #       %{event: "sync_all", topic: <<"display:", _display_id::binary>>, payload: assigns} = ev,
  #       socket
  #     ) do
  #   Logger.debug(inspect(ev))
  #   Logger.debug("Received Sync All")
  #   {:noreply, assign(socket, Map.take(assigns, @sync_all_keys))}
  # end

  # defp simple_sync_event(socket), do: {:noreply, send_sync_all(socket)}

  # defp process_content(content) do
  #   content |> String.trim() |> String.split("\n")
  # end

  # def handle_event("remove_song_at", %{"index" => index}, socket) do
  #   {:ok, playlist} = Playlist.remove_song_at(socket.assigns.playlist, String.to_integer(index))

  #   socket
  #   |> assign(playlist: playlist)
  #   |> set_current_song_and_load()
  #   |> simple_sync_event()
  # rescue
  #   err ->
  #     Logger.error(inspect(err))
  #     simple_sync_event(socket)
  # end

  # def handle_event("set_current_song", %{"index" => index}, socket) do
  #   i = String.to_integer(index)

  #   cond do
  #     i == socket.assigns.display.current_song_index ->
  #       {:noreply, socket}

  #     true ->
  #       {:noreply,
  #        socket
  #        |> set_current_slide(0)
  #        |> set_current_song_and_load(i)
  #        |> send_sync_all()}
  #   end
  # end

  # def handle_event("prev_song", _, socket) do
  #   {:noreply,
  #    socket
  #    |> set_current_slide(0)
  #    |> set_current_song_and_load(socket.assigns.display.current_song_index - 1)
  #    |> send_sync_all()}
  # end

  # def handle_event("next_song", _, socket) do
  #   {:noreply,
  #    socket
  #    |> set_current_slide(0)
  #    |> set_current_song_and_load(socket.assigns.display.current_song_index + 1)
  #    |> send_sync_all()}
  # end

  # def handle_event("prev_slide", _, socket) do
  #   {:noreply,
  #    socket
  #    |> set_current_slide(socket.assigns.display.current_slide_index - 1)
  #    |> set_current_song_and_load()
  #    |> send_sync_all()}
  # end

  # def handle_event("next_slide", _, socket) do
  #   {:noreply,
  #    socket
  #    |> set_current_slide(socket.assigns.display.current_slide_index + 1)
  #    |> set_current_song_and_load()
  #    |> send_sync_all()}
  # end

  # def handle_event("set_add_slide_type", %{"slide-type" => type}, socket),
  #   do: {:noreply, set_add_slide_type(socket, type)}

  # def handle_event("set_current_slide", %{"index" => index}, socket) do
  #   i = String.to_integer(index)

  #   cond do
  #     i == socket.assigns.display.current_slide_index ->
  #       {:noreply, socket}

  #     true ->
  #       {:noreply,
  #        socket
  #        |> set_current_slide(i)
  #        |> send_sync_all()}
  #   end
  # end

  # def handle_event("suggest_song", %{"song" => search_term}, socket) do
  #   # search is handled by the datalist containing all songs.
  #   # TODO: word boundary searching?
  #   # TODO: reload song list when file system changes?
  #   # suggested_songs = Enum.filter(songs, &(String.contains?(String.downcase(&1), String.downcase(search_term))))
  #   # {:noreply, assign(socket, suggested_songs: suggested_songs)}
  #   exists? = Song.File.exists?(search_term)
  #   new_song_allowed? = search_term != "" && !exists?
  #   add_song_allowed? = search_term != "" && exists?
  #   Logger.debug(inspect({search_term, exists?, new_song_allowed?, add_song_allowed?}))

  #   {:noreply,
  #    socket
  #    |> assign(
  #      new_song_allowed?: new_song_allowed?,
  #      add_song_allowed?: add_song_allowed?
  #    )}
  # end

  # def handle_event("cancel_add_song", _, socket), do: {:noreply, close_all_modals(socket)}
  # def handle_event("cancel_add_slide", _, socket), do: {:noreply, close_all_modals(socket)}
  # def handle_event("begin_add_slide", _, socket), do: {:noreply, show_add_slide_form(socket)}

  # def handle_event("suggest_slide", %{} = args, %{assigns: %{add_slide_type: type}} = socket) do
  #   name = Map.get(args, "id", "")
  #   content = Map.get(args, "content", "")

  #   existing_slides =
  #     Display.current_song(socket.assigns.display)
  #     |> elem(1)
  #     |> Song.named_slides()
  #     |> Enum.map(& &1.id)

  #   valid? =
  #     case type do
  #       "bare" ->
  #         true

  #       # TODO: show a warning that the slide will be blank if the name doesn't exist?
  #       "ref" ->
  #         true

  #       "named" ->
  #         socket.assigns.edit_slide_id != nil || (name != "" && !(name in existing_slides))

  #       "repeat" ->
  #         true
  #     end

  #   {:noreply, assign(socket, add_slide_valid?: valid?)}
  # end

  # def handle_event("add_slide", args, %{assigns: %{edit_slide_at: n}} = socket)
  #     when is_integer(n) do
  #   num_slides = Display.num_slides(socket.assigns.display)

  #   {:noreply, socket} =
  #     handle_event(
  #       "remove_slide",
  #       %{"at" => Integer.to_string(n)},
  #       assign(socket, edit_slide_at: nil)
  #     )

  #   {:noreply, socket} = handle_event("add_slide", args, socket)
  #   Logger.warn(inspect({socket, num_slides, n}, pretty: true))

  #   {:noreply, reorder_slide(socket, num_slides - 2, n - 0)}
  # end

  # def handle_event("add_slide", %{"id" => name}, %{assigns: %{add_slide_type: "ref"}} = socket) do
  #   # do_append_slide(socket, %SongVerse{type: :ref, id: name})
  #   socket
  # end

  # def handle_event(
  #       "add_slide",
  #       %{"content" => content, "id" => name},
  #       %{assigns: %{add_slide_type: "named"}} = socket
  #     ) do
  #   # do_append_slide(socket, %SongVerse{type: :named, id: name, content: process_content(content)})
  #   socket
  # end

  # def handle_event(
  #       "add_slide",
  #       %{"content" => content},
  #       %{assigns: %{add_slide_type: "bare"}} = socket
  #     ) do
  #   # do_append_slide(socket, %SongVerse{type: :bare, content: process_content(content)})
  #   socket
  # end

  # def handle_event("add_slide", _, %{assigns: %{add_slide_type: "repeat"}} = socket) do
  #   # do_append_slide(socket, %SongVerse{type: :ref, id: "Repeat"})
  #   socket
  # end

  # def handle_event("copy_slide", %{"at" => str_at}, socket) do
  #   at = String.to_integer(str_at)

  #   case current_song(socket) do
  #     {:ok, song} ->
  #       {:noreply,
  #        song.verses
  #        |> Enum.at(at)
  #        |> case do
  #          nil ->
  #            socket

  #          %SongVerse{type: :bare} = sv ->
  #            set_current_song_verses(socket, List.insert_at(song.verses, at, sv))

  #          %SongVerse{type: :ref} = sv ->
  #            set_current_song_verses(socket, List.insert_at(song.verses, at, sv))

  #          %SongVerse{type: :named, id: id} ->
  #            set_current_song_verses(
  #              socket,
  #              List.insert_at(song.verses, at, %SongVerse{type: :ref, id: id})
  #            )
  #        end}

  #     err ->
  #       Logger.error(inspect(err))
  #       {:noreply, socket}
  #   end
  # end

  # def handle_event("edit_slide", %{"at" => str_at}, socket) do
  #   at = String.to_integer(str_at)
  #   {:ok, song} = Display.current_song(socket.assigns.display)
  #   sv = Song.verse_at(song, at)

  #   type =
  #     case sv do
  #       %{type: :ref, id: id} ->
  #         if String.downcase(id) == "repeat", do: "repeat", else: "reference"

  #       %{type: :named} ->
  #         "named"

  #       %{type: :bare} ->
  #         "bare"
  #     end

  #   {:noreply,
  #    socket
  #    |> show_add_slide_form()
  #    |> assign(
  #      edit_slide_at: at,
  #      edit_slide_id: sv.id,
  #      edit_slide_content: SongVerse.content(sv),
  #      add_slide_type: type,
  #      add_slide_valid?: true
  #    )}
  # end

  # # TODO: Add an "are you sure" if the verse is a named verse?
  # def handle_event("remove_slide", %{"at" => str_at}, socket) do
  #   at = String.to_integer(str_at)

  #   case current_song(socket) do
  #     {:ok, song} ->
  #       {:noreply, set_current_song_verses(socket, List.delete_at(song.verses, at))}

  #     err ->
  #       Logger.error(inspect(err))
  #       {:noreply, socket}
  #   end
  # end

  # # TODO: add_song events need to have the playlist bound to the form/event so that if the playlist changes from underneath, we won't add the song to the newly active playlist
  # # maybe this is actually expected functinality?
  # # Needs thought
  # def handle_event("add_song", %{"song" => song_name, "add_song_type" => "newsong"}, socket) do
  #   {:ok, song} = Song.new(song_name)
  #   {:ok, playlist} = Playlist.append_song(socket.assigns.playlist, song)

  #   socket
  #   |> assign(playlist: playlist)
  #   |> close_all_modals()
  #   |> set_current_slide(0)
  #   |> set_current_song_and_load(Enum.count(playlist.songs))
  #   |> simple_sync_event()
  # rescue
  #   err ->
  #     Logger.error(inspect(err))
  #     simple_sync_event(socket)
  #     {:noreply, socket}
  # end

  # def handle_event("add_song", %{"song" => song} = arg, socket) do
  #   Logger.warn(inspect(arg))

  #   {:noreply,
  #    socket
  #    |> close_all_modals()
  #    |> add_song_to_playlist(song)
  #    |> send_sync_all()}
  # end

  # def handle_event("add_song", _, socket) do
  #   {:noreply,
  #    socket
  #    |> show_add_song_form()}
  # end

  # # user didn't actually move it -- noop
  # def handle_event("dropped", %{"new_at" => at, "old_at" => at, "type" => type}, socket),
  #   do: {:noreply, socket}

  # def handle_event("dropped", %{"new_at" => new_at, "old_at" => old_at, "type" => type}, socket) do
  #   case type do
  #     "slides" ->
  #       {:noreply,
  #        socket
  #        |> reorder_slide(old_at, new_at)
  #        |> send_sync_all()}

  #     "songlist" ->
  #       {:noreply,
  #        socket
  #        |> reorder_song(old_at, new_at)
  #        |> send_sync_all()}
  #   end
  # end

  # def handle_event("toggle_hidden", _path, socket) do
  #   {:ok, display} = Display.toggle_hidden(socket.assigns.display)

  #   {:noreply,
  #    socket
  #    |> assign(display: display)
  #    |> send_sync_all()}
  # end

  # def handle_event("toggle_frozen", _path, socket) do
  #   {:ok, display} = Display.toggle_frozen(socket.assigns.display)

  #   {:noreply,
  #    socket
  #    |> assign(display: display)
  #    |> send_sync_all()}
  # end

  # def handle_event("toggle_freeze", _path, socket), do: {:noreply, socket}

  # def handle_event("nav", _path, socket), do: {:noreply, socket}

  # def handle_event("hide_sidebar", _path, socket),
  #   do: {:noreply, assign(socket, show_sidebar?: false)}

  # def handle_event("show_sidebar", _path, socket),
  #   do: {:noreply, assign(socket, show_sidebar?: true)}

  # def handle_event("key", %{"key" => "Escape"}, %{assigns: %{in_modal?: true}} = socket) do
  #   {:noreply, close_all_modals(socket)}
  # end

  # def handle_event("key", _, %{assigns: %{in_modal?: true}} = socket), do: {:noreply, socket}

  # def handle_event("key", %{"key" => "p"}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("toggle_hidden", %{}, socket)

  # def handle_event("key", %{"key" => "h"}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("prev_slide", %{}, socket)

  # def handle_event("key", %{"key" => "k"}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("prev_slide", %{}, socket)

  # def handle_event("key", %{"key" => "j"}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("next_slide", %{}, socket)

  # def handle_event("key", %{"key" => "l"}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("next_slide", %{}, socket)

  # def handle_event("key", %{"key" => " "}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("toggle_hidden", %{}, socket)

  # def handle_event("key", %{"key" => "f"}, %{assigns: %{in_modal?: false}} = socket),
  #   do: handle_event("toggle_frozen", %{}, socket)

  # def handle_event("key", %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowUp"}, socket),
  #   do: handle_event("prev_song", %{}, socket)

  # def handle_event(
  #       "key",
  #       %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowLeft"},
  #       socket
  #     ),
  #     do: handle_event("prev_song", %{}, socket)

  # def handle_event(
  #       "key",
  #       %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowRight"},
  #       socket
  #     ),
  #     do: handle_event("next_song", %{}, socket)

  # def handle_event(
  #       "key",
  #       %{"ctrlKey" => true, "shiftKey" => false, "key" => "ArrowDown"},
  #       socket
  #     ),
  #     do: handle_event("next_song", %{}, socket)

  # def handle_event("key", %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowUp"}, socket),
  #   do: handle_event("prev_slide", %{}, socket)

  # def handle_event(
  #       "key",
  #       %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowLeft"},
  #       socket
  #     ),
  #     do: handle_event("prev_slide", %{}, socket)

  # def handle_event(
  #       "key",
  #       %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowRight"},
  #       socket
  #     ),
  #     do: handle_event("next_slide", %{}, socket)

  # def handle_event(
  #       "key",
  #       %{"ctrlKey" => false, "shiftKey" => false, "key" => "ArrowDown"},
  #       socket
  #     ),
  #     do: handle_event("next_slide", %{}, socket)

  # def handle_event("key", k, socket) do
  #   Logger.debug("Key Event: #{inspect(k)}")
  #   {:noreply, socket}
  # end
end
