defmodule LyricScreen.Song.Parser do
	@moduledoc """
	Contains functions for parsing song files.
	"""

	import NimbleParsec
	import LyricScreen.ParserHelpers

	@ascii_newline 10
	@verse_name_delim ?:
	@metadata_delim @verse_name_delim
	@verse_ref_pref ?(
	@verse_ref_suff ?)

	title = non_empty_line() |> unwrap_and_tag(:title)
	named_metadata_element =
		ascii_string([not: @metadata_delim, not: @ascii_newline], min: 1)
		|> ignore(ascii_char([@metadata_delim]))
		|> ignore(repeat(ascii_char([?\s, ?\n, ?\t]))) # ignore whitespace following delim
		|> non_empty_line()
		|> tag(:meta_named)
	bare_metadata_element = non_empty_line() |> tag(:meta_bare)

	metadata =
		optional(
			times(choice([named_metadata_element, bare_metadata_element]), min: 1)
			|> tag(:metadata)
		)

	named_verse =
		ascii_string([not: @verse_name_delim], min: 1)
		|> unwrap_and_tag(:verse_name)
		|> ignore(ascii_char([@verse_name_delim]))
		|> ignore(eol())
		|> non_empty_line_chunk()
		|> unwrap_and_tag(:named_verse)

	ref_verse =
		ignore(ascii_char([@verse_ref_pref]))
		|> ascii_string([not: @verse_ref_suff], min: 1)
		|> ignore(ascii_char([@verse_ref_suff]))
		|> unwrap_and_tag(:verse_ref)

	bare_verse = non_empty_line_chunk() |> unwrap_and_tag(:bare_verse)
	verse = choice([ref_verse, named_verse, bare_verse]) |> ignore(choice([empty_line(), eos()]))

	defparsec :raw_data,
		title
		|> optional(metadata)
		|> ignore(repeat(empty_line()))
		|> optional(
			repeat(verse)
			|> ignore(repeat(empty_line()))
			|> ignore(eos())
		)
end

defmodule LyricScreen.Song.File do
	@moduledoc """
	Contains functions managing song files.
	"""

	@songs_dir "src/priv/data/songs/"

	alias LyricScreen.Song.Parser

	defp song_file?(f) do
		String.ends_with?(f, ".txt")
	end

	def default_dir, do: @songs_dir

	def ls do
		case File.ls(@songs_dir) do
			{:ok, files} ->
				keys =
					files
					|> Enum.filter(&song_file?/1)
					|> Enum.map(&(String.trim_trailing(&1, ".txt")))
				{:ok, keys}
			{:error, _reason} = err -> err
		end
	end

	def content(f) do
		ff = Path.join(@songs_dir, f <> ".txt")
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
		case ls do
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

	defp content_string(content), do: Enum.join(content, "\n")

	def serialize(%__MODULE__{type: :bare, content: content}), do: content_string(content)
	def serialize(%__MODULE__{type: :ref, content: content}), do: "(#{content_string(content)})"
	def serialize(%__MODULE__{type: :named, key: key, content: content}), do: "#{key}\n#{content_string(content)}"
end

defmodule LyricScreen.Song do
	@moduledoc """
	Defines the struct for a song.
	"""

	alias LyricScreen.Song.File, as: F
	alias LyricScreen.SongVerse

	require Logger

	defstruct [
		key: nil,
		display_title: "Song Title",
		metadata: [],
		verses: [],
	]

	def load_from_string(str), do: F.data(str) |> do_load()
	def load_from_file(title), do: F.file_data(title) |> do_load()

	defp do_load(raw_data) do
		Logger.warn(inspect(raw_data))
		# TODO: need post-processing into struct
	end

	def to_binary_stream(%__MODULE__{} = song) do
		Stream.concat([
			[song.display_title, "\n\n"],
			Stream.map(song.metadata, &serialize_metadata/1),
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
		|> Stream.into(File.stream!(Path.join(F.default_dir(), key <> ".txt.new"), [:write, :utf8]))
		File.rename!(Path.join(F.default_dir(), key <> ".txt.new"), Path.join(F.default_dir(), key <> ".txt"))

		:ok
	rescue
		err ->
			Logger.error(inspect(err))
			:error
	end

	defp serialize_metadata({key, val}), do: "#{key}: #{val}"
	defp serialize_metadata(x), do: to_string(x)
end
