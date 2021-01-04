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

	alias LyricScreen.{Playlist, Song, SongVerse}
	alias LyricScreen.Display.File, as: F
	require Logger

	defstruct [
		# TODO: show_titles?: true,
		# TODO: show_performer_metadata?: true,
		key: nil,
		playlist: "default",
		current_song_index: 0,
		current_slide_index: 0,
		frozen?: false,
		hidden?: false,
	]

	def load_from_file(f), do: F.parse_file(f)
	def save_to_file(%__MODULE__{key: key} = display) do
		:ok = File.write(Path.join(F.dir(), key <> ".txt"), :erlang.term_to_binary(display))
		{:ok, display}
	end

	def playlist(%__MODULE__{playlist: playlist}), do: Playlist.load_from_file(playlist)

	def songs(%__MODULE__{} = display) do
		case playlist(display) do
			{:ok, playlist} -> Playlist.songs(playlist)
			err ->
				Logger.error(inspect(err))
				err
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
			{:ok, song} -> {:ok, Song.map(song)}
			err ->
				Logger.error(inspect(err))
				err
		end
	end

	def current_slide(%__MODULE__{current_slide_index: i} = display) do
		case current_slides(display) do
			{:ok, slides} -> {:ok, Enum.at(slides, i)}
			err ->
				Logger.error(inspect(err))
				err
		end
	end

	def set_current_song_index(%__MODULE__{} = display, index \\ nil) do
    i = index || display.current_song_index
		Logger.debug("Setting Current Song Index: #{i}")
    num_songs =
			case playlist(display) do
				{:ok, playlist} -> Enum.count(playlist.songs)
				_ -> 0
			end
		old_display = display
		display = %{display | current_song_index: i}
    cond do
      i >= 0 and i < num_songs -> display
			num_songs > 0 and i >= num_songs ->
				{:ok, display} = set_current_song_index(display, i - 1)
				display
      true -> old_display
    end
		|> save_to_file()
	end

	def set_current_slide_index(%__MODULE__{} = display, index \\ nil) do
    i = index || display.current_slide_index
    s = display.current_song_index
		Logger.debug("Setting Current Slide Index: #{i}")
		old_display = display
		# TODO: rescue
		{:ok, slides} = current_slides(display)
		num_slides = slides |> Enum.count()
    num_songs =
			case playlist(display) do
				{:ok, playlist} -> Enum.count(playlist.songs)
				_ -> 0
			end
		display = %{display | current_slide_index: i}
		cond do
			# TODO: check if song navigation is even possible - may be a noop
			i == -1 && s > 0 ->
				{:ok, display} = set_current_song_index(%{display | current_slide_index: 0}, display.current_song_index - 1)
				save_to_file(display)
			i == num_slides && s < num_songs - 1 ->
				{:ok, display} = set_current_song_index(%{display | current_slide_index: 0}, display.current_song_index + 1)
				save_to_file(display)
			i >= 0 and i < num_slides -> {:ok, display}
			num_slides > 0 and i >= num_slides ->
				{:ok, display} = set_current_slide_index(display, i - 1)
				save_to_file(display)
			true -> {:ok, old_display}
		end
	end

	def set_playlist(%__MODULE__{} = display, p), do: %{display | playlist: p} |> save_to_file()
end
