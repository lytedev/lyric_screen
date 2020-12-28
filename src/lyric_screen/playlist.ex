defmodule LyricScreen.Playlist.File do
	def dir, do: Application.get_env(:lyric_screen, :playlists_dir)

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
		[display_title | songs] =
			str |> String.trim() |> String.split("\n", trim: true)

		{:ok, {display_title, songs}}
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

defmodule LyricScreen.Playlist do
	alias LyricScreen.Playlist.File, as: F

	require Logger

	defstruct [
		key: nil,
		display_title: "Playlist Title",
		songs: [],
	]

	def load_from_string(str, key \\ nil), do: str |> F.parse() |> do_load(key)
	def load_from_file(title), do: title |> F.parse_file() |> do_load(title)

	defp do_load({:ok, {display_title, songs}}, key) do
		Logger.warn(inspect(songs))
		{:ok, %__MODULE__{
			key: key,
			display_title: display_title,
			songs: songs
		}}
	end

	def to_binary_stream(%__MODULE__{} = playlist) do
		Stream.concat([
			[playlist.display_title, "\n\n"],
			playlist.songs |> Stream.intersperse("\n")
		])
	end

	def to_iodata(%__MODULE__{} = playlist) do
		playlist
		|> to_binary_stream()
		|> Enum.to_list()
	end

	def save_to_file(%__MODULE__{key: key} = playlist) when is_binary(key) do
		playlist
		|> to_binary_stream
		|> Stream.into(File.stream!(Path.join(F.dir(), key <> ".txt.new"), [:create, :utf8]))
		|> Stream.run()
		File.rename!(Path.join(F.dir(), key <> ".txt.new"), Path.join(F.dir(), key <> ".txt"))

		{:ok, playlist}
	rescue
		err ->
			Logger.error(inspect(err))
			:error
	end

	##################

	def remove_song_at(%__MODULE__{} = playlist, index) do
		%{playlist | songs: List.delete_at(playlist.songs, index)}
		|> save_to_file()
	end
end
