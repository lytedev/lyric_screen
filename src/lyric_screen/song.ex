defmodule LyricScreen.Song.Parser do
	@moduledoc """
	Contains functions for parsing song files.
	"""

	import NimbleParsec
	import LyricScreen.ParserHelpers

	@newline 10
	@verse_name_delim ?:
	@metadata_delim @verse_name_delim
	@verse_ref_pref ?(
	@verse_ref_suff ?)

	title = trimmed_non_empty_line() |> unwrap_and_tag(:title)
	named_metadata_element =
		utf8_string([not: @metadata_delim, not: @newline], min: 1)
		|> ignore(utf8_char([@metadata_delim]))
		|> ignore(repeat(ws())) # ignore whitespace following delim
		|> trimmed_non_empty_line()
		|> tag(:meta_named)
	bare_metadata_element = trimmed_non_empty_line() |> tag(:meta_bare)

	metadata =
		optional(
			times(choice([named_metadata_element, bare_metadata_element]), min: 1)
			|> tag(:metadata)
		)

	named_verse =
		utf8_string([not: @verse_name_delim, not: @newline], min: 1)
		|> unwrap_and_tag(:verse_name)
		|> ignore(utf8_char([@verse_name_delim]))
		|> ignore(repeat(s()))
		|> ignore(eol())
		|> trimmed_non_empty_line_chunk()
		|> unwrap_and_tag(:named_verse)

	ref_verse =
		ignore(utf8_char([@verse_ref_pref]))
		|> ignore(repeat(s()))
		|> utf8_string([not: @verse_ref_suff, not: @newline], min: 1)
		|> ignore(repeat(s()))
		|> ignore(utf8_char([@verse_ref_suff]))
		|> ignore(repeat(s()))
		|> ignore(eosl())
		|> lookahead(choice([utf8_char([@newline]), eos()]))
		|> unwrap_and_tag(:verse_ref)

	bare_verse = trimmed_non_empty_line_chunk() |> unwrap_and_tag(:bare_verse)
	verse = choice([named_verse, ref_verse, bare_verse]) |> ignore(choice([times(empty_line(), min: 1), eos()]))

	defparsec :raw_data,
		title
		|> optional(metadata)
		|> ignore(repeat(empty_line()))
		|> optional(
			repeat(verse)
			|> tag(:verses)
		)
		|> ignore(repeat(empty_line()))
		|> ignore(eos())
end

defmodule LyricScreen.Song.File do
	@moduledoc """
	Contains functions managing song files.
	"""

	alias LyricScreen.Song.Parser

	defp song_file?(f) do
		String.ends_with?(f, ".txt")
	end

	def dir, do: Application.get_env(:lyric_screen, :songs_dir)

	def exists?(key), do: File.exists?(Path.join(dir(), key <> ".txt"))

	def ls do
		case File.ls(dir()) do
			{:ok, files} ->
				keys =
					files
					|> Enum.filter(&song_file?/1)
					|> Enum.map(&(String.trim_trailing(&1, ".txt")))
				{:ok, keys}
			{:error, _reason} = err -> err
		end
	end

	def content(f) when is_binary(f) do
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
	def content(_), do: {:error, "no file name"}

	def file_data(f) do
		case content(f) do
			{:ok, content} -> data(content)
			{:error, _reason} = err -> err
		end
	end

	def data(song_contents) do
		case Parser.raw_data(song_contents) do
			{:ok, acc, _rem, _meta, {_line, _col}, _n} -> {:ok, acc}
			{:error, _reason, _rem, _meta, {_line, _col}, _n} = err -> err
		end
	end

	# TODO: parallelize?
	def all_data do
		case ls() do
			{:ok, f} -> Enum.map(f, &{&1, file_data(&1)})
			{:error, _reason} = err -> err
		end
	end
end

defmodule LyricScreen.SongVerse do
	@moduledoc """
	Defines the struct for a verse in a song.
	"""

	defstruct [
		type: :bare,
		key: nil,
		content: [""],
	]

	def content(%__MODULE__{content: content}), do: content(content)
	def content(content) when is_list(content), do: Enum.join(content, "\n")

	def serialize(%__MODULE__{type: :bare} = sv), do: content(sv)
	def serialize(%__MODULE__{type: :ref, key: key}), do: "(#{key})"
	def serialize(%__MODULE__{type: :named, key: key} = sv), do: "#{key}:\n#{content(sv)}"
end

defmodule LyricScreen.Song do
	@moduledoc """
	Defines the struct for a song.
	"""

	alias LyricScreen.Song.File, as: F
	alias LyricScreen.SongVerse

	require Logger

	# TODO: adding fields to this may break all users' data?
	defstruct [
		key: nil,
		display_title: "Song Title",
		metadata: [],
		verses: [],
	]

	def load_from_string(str), do: F.data(str) |> do_load()
	def load_from_file(title), do: F.file_data(title) |> do_load(title)

	def named_slides(%__MODULE__{verses: verses}) do
		Enum.filter(verses, &(&1.type == :named))
	end

	defp do_load(raw_data, key \\ nil)
	defp do_load({:ok, data_kw} = _raw_data, key) do
		title = Keyword.get(data_kw, :title, "Song Title")
		metadata = Keyword.get(data_kw, :metadata, [])
		verses =
			data_kw
			|> Keyword.get(:verses, [])
			|> Enum.map(&map_raw_verse/1)

		{:ok, %__MODULE__{
			key: key,
			display_title: title,
			metadata: metadata,
			verses: verses,
		}}
	end
	defp do_load(err, key), do: {:error, {err, key}}

	def get_named_verse(%__MODULE__{verses: verses}, name, default \\ nil) do
		default = default || %SongVerse{type: :bare, key: name, content: [""]}
		case Enum.find(verses, fn v -> v.key == name && v.type == :named end) do
			%SongVerse{} = msv -> msv
			_ -> default
		end
	end

	def slide_at(%__MODULE__{} = song, i), do: Enum.at(map(song), i)
	def verse_at(%__MODULE__{} = song, i), do: Enum.at(song.verses, i)

	def map(song, map_name \\ "@default")
	def map(%__MODULE__{verses: verses, display_title: title} = song, "@default") do
		mapped_verses =
			verses
			|> Enum.reduce({{"@title", [title]}, []}, fn (v, {last, acc}) ->
				add =
					case v do
						%SongVerse{type: :bare} = sv -> {"", sv}
						%SongVerse{type: :named} = sv -> {sv.key, sv}
						%SongVerse{type: :ref, key: key} ->
							if String.downcase(key) == "repeat" do
								{key, elem(last, 1)}
							else
								{key, get_named_verse(song, key)}
							end
					end
				{add, [add | acc]}
			end)
			|> elem(1)
			|> Enum.map(fn {key, sv} -> {key, SongVerse.content(sv)} end)
			|> Enum.reverse()
		[{"@title", title} | mapped_verses]
	end

	defp map_raw_verse({:bare_verse, content}), do: %SongVerse{type: :bare, content: content}
	defp map_raw_verse({:verse_ref, content}), do: %SongVerse{type: :ref, key: content, content: []}
	defp map_raw_verse({:named_verse, [{:verse_name, key} | content]}), do: %SongVerse{type: :named, content: content, key: key}

	def to_binary_stream(%__MODULE__{} = song) do
		Stream.concat([
			[song.display_title, "\n"],
			Stream.map(song.metadata, &serialize_metadata/1),
			["\n\n"],
			song.verses
				|> Stream.map(&SongVerse.serialize/1)
				|> Stream.intersperse("\n\n")
		])
	end

	def to_iodata(%__MODULE__{} = song) do
		song
		|> to_binary_stream()
		|> Enum.to_list()
	end

	def save_to_file(%__MODULE__{key: key} = song) do
		song
		|> to_binary_stream
		|> Stream.into(File.stream!(Path.join(F.dir(), key <> ".txt.new"), [:write, :utf8]))
		|> Stream.run()
		File.rename!(Path.join(F.dir(), key <> ".txt.new"), Path.join(F.dir(), key <> ".txt"))

		{:ok, song}
	rescue
		err ->
			Logger.error(inspect(err))
			{:error, err}
	end

	defp serialize_metadata({:meta_named, [name, rest]}) do
		"#{name}: #{rest}"
	end
	defp serialize_metadata({key, val}) when is_binary(val), do: "#{key}: #{val}"
	defp serialize_metadata(x), do: to_string(x)

	def set_verses(%__MODULE__{} = song, verses), do: %{song | verses: verses} |> save_to_file()

	def new(key, title \\ nil)
	def new(key, ""), do: new(key, nil)
	def new(key, nil), do: new(key, key)
	def new(key, title) when is_binary(key) and is_binary(title) do
		if F.exists?(key) do
			{:error, "song_already_exists"}
		else
			%__MODULE__{
				key: key,
				display_title: title,
				metadata: [],
				verses: [],
			}
			|> save_to_file()
		end
	end
end
