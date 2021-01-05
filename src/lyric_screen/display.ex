defmodule LyricScreen.Display.File do
	@moduledoc false

	def dir, do: Application.get_env(:lyric_screen, :displays_dir)

	defp valid_file?(f) do
		String.ends_with?(f, ".txt")
	end

	def ls do
		case File.ls(dir()) do
			{:ok, files} ->
				keys =
					files
					|> Enum.filter(&valid_file?/1)
					|> Enum.map(&(String.trim_trailing(&1, ".txt")))
				{:ok, keys}
			{:error, _reason} = err -> err
		end
	end

	def exists?(key), do: File.exists?(Path.join(dir(), key <> ".txt"))

	def content(f) do
		ff = Path.join(dir(), f <> ".txt")
		case File.read(ff) do
			{:ok, content} ->
				clean_content =
					content
					|> String.replace("\r\n", "\n")
					|> String.trim()
				{:ok, clean_content}
			{:error, _reason} = err -> err
		end
	end

	def parse(str) do
		case :erlang.binary_to_term(str) do
			%{} = display -> {:ok, display}
			err -> {:error, err}
		end
	end

	def parse_file(f) do
		case content(f) do
			{:ok, content} -> parse(content)
			err -> {:error, err}
		end
	rescue
		err -> {:error, err}
	end
end

defmodule LyricScreen.Display do
	@moduledoc false

	alias LyricScreen.{Playlist, Song}
	alias LyricScreen.Display.File, as: F
	require Logger

	# TODO: adding fields to this may break all users' data?
	defstruct [
		# TODO: show_titles?: true,
		# TODO: show_performer_metadata?: true,
		key: nil,
		playlist: "default",
		current_song_index: 0,
		current_slide_index: 0,
		frozen?: false,
		frozen_song: nil,
		frozen_slide: nil,
		hidden?: false,
	]

	def load_from_file(f) do
		case F.parse_file(f) do
			{:ok, display} -> {:ok, Map.merge(%__MODULE__{}, display)}
			{:error, err} -> {:error, err}
			# err -> {:error, err}
		end
	end

	def save_to_file(%__MODULE__{key: key} = display) do
		:ok = File.write(Path.join(F.dir(), key <> ".txt"), :erlang.term_to_binary(display))
		{:ok, display}
	end

	def playlist(%__MODULE__{playlist: playlist}), do: Playlist.load_from_file(playlist)

	def songs(%__MODULE__{} = display) do
		case playlist(display) do
			{:ok, playlist} -> Playlist.songs(playlist)
			err ->
				Logger.warn("Error while getting display's playlist's songs: #{inspect(err)}")
				[]
		end
	end

	def song_at(display, song_index \\ nil)
	def song_at(display, nil), do: song_at(display, display.current_song_index)
	def song_at(display, song_index) do
		case playlist(display) do
			{:ok, playlist} -> Playlist.song_at(playlist, song_index)
			err -> err
		end
	end

	def current_song(%__MODULE__{current_song_index: i} = display) do
		case playlist(display) do
			{:ok, playlist} -> Playlist.song_at(playlist, i)
			err ->
				Logger.error(inspect(err))
				err
		end
	end

	def current_slides(%__MODULE__{} = display) do
		case current_song(display) do
			{:ok, song} -> Song.map(song)
			err ->
				Logger.warn("Error while getting display's current slides: #{inspect(err)}")
				[]
		end
	end

	def slide_at(display, song_index \\ nil, slide_index \\ nil)
	def slide_at(display, nil, nil) do
		slide_at(display, display.current_song_index, display.current_slide_index)
	end
	def slide_at(display, song_index, slide_index) do
		with {_, {:ok, playlist}} <- {:playlist, playlist(display)},
				 {_, {:ok, song}} <- {:song, Playlist.song_at(playlist, song_index)},
				 {_, slide} <- {:slide, Song.verse_at(song, slide_index)}
		do
			{:ok, slide}
		else
			{:playlist, err} -> err
			{:song, err} -> err
			{:slide, err} -> err
			{:error, err} -> {:error, err}
		end
	end

	def current_slide(%__MODULE__{current_slide_index: i} = display) do
		case current_slides(display) do
			# TODO: case Enum.at...
			[] -> {:error, :no_slides}
			slides ->
				case Enum.at(slides, i) do
					nil -> {:error, ["No slide ", i, " in ", slides]}
					{title, content} -> {title, content}
				end
		end
	end

	def num_songs(%__MODULE__{} = display) do
		case playlist(display) do
			{:ok, playlist} -> Enum.count(playlist.songs)
			_ -> 0
		end
	end

	def num_slides(%__MODULE__{} = display), do: display |> current_slides() |> Enum.count()

	def set_current_song_index(%__MODULE__{} = display, nil), do: set_current_song_index(display, display.current_song_index)
	def set_current_song_index(%__MODULE__{} = display, i) do
		num_songs = num_songs(display)
		new_display = %{display | current_song_index: i}
    cond do
      i >= 0 and i < num_songs -> new_display
			num_songs > 0 and i >= num_songs -> {:ok, d} = set_current_song_index(new_display, i - 1); d
      true -> display
    end
		|> save_to_file()
	end

	def set_current_slide_index(%__MODULE__{} = display, nil), do: set_current_slide_index(display, display.current_slide_index)
	def set_current_slide_index(%__MODULE__{current_song_index: csi} = display, i) do
		# TODO: rescue
		num_slides = num_slides(display)
    num_songs = num_songs(display)
		new_display = %{display | current_slide_index: i}
		cond do
			# TODO: check if song navigation is even possible - may be a noop
			i == -1 && csi > 0 ->
				{:ok, display} = set_current_song_index(%{new_display | current_slide_index: 0}, csi - 1)
				save_to_file(display)
			i == num_slides && csi < num_songs - 1 ->
				{:ok, display} = set_current_song_index(%{new_display | current_slide_index: 0}, csi + 1)
				save_to_file(display)
			i >= 0 and i < num_slides ->
				save_to_file(new_display)
			num_slides > 0 and i >= num_slides ->
				{:ok, display} = set_current_slide_index(new_display, i - 1)
				save_to_file(display)
			true -> {:ok, display}
		end
	end

	def set_playlist(%__MODULE__{} = display, p), do: %{display | playlist: p} |> save_to_file()

	def toggle_hidden(%__MODULE__{hidden?: hidden?} = display), do: %{display | hidden?: !hidden?} |> save_to_file()

	def toggle_frozen(%__MODULE__{frozen?: frozen?} = display) do
		IO.inspect(display)
		if frozen? do
			%{display | frozen?: false, frozen_song: nil, frozen_slide: nil} |> save_to_file()
		else
			%{display | frozen?: true, frozen_song: display.current_song_index, frozen_slide: display.current_slide_index} |> save_to_file()
		end
	end

	def can_prev_song?(%__MODULE__{current_song_index: csi}), do: csi > 0
	def can_next_song?(%__MODULE__{current_song_index: csi} = display) do
		csi < num_songs(display) - 1
	end

	def can_prev_slide?(%__MODULE__{current_slide_index: csi} = display) do
		csi > 0 || can_prev_song?(display)
	end
	def can_next_slide?(%__MODULE__{current_slide_index: csi} = display) do
		csi < num_slides(display) - 1 || can_next_song?(display)
	end
end
