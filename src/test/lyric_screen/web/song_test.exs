defmodule LyricScreen.SongParserTest do
	use ExUnit.Case, async: true
	doctest LyricScreen.Song.File
	doctest LyricScreen.Song.Parser
	doctest LyricScreen.Song

	alias LyricScreen.Song.Parser

	defmacrop assert_parser_raw_data_results(song_contents, pattern) do
		quote do
			assert unquote(pattern) = Parser.raw_data(unquote(song_contents))
		end
	end

	describe "parser" do
		test "fails to parse empty song data" do
			assert_parser_raw_data_results("", {:error, _, _, %{}, {_, _}, _})
		end

		test "fails to parse songs without a title as the first line" do
			assert_parser_raw_data_results("\n", {:error, _, _, %{}, {_, _}, _})
			assert_parser_raw_data_results("\nSong Title", {:error, _, _, %{}, {_, _}, _})
		end

		test "parses simplest possible song" do
			assert_parser_raw_data_results("a", {:ok, [title: "a"], "", %{}, {_, _}, _})
		end

		test "parses basic song regardless of trailing newlines" do
			song_contents =
				"""
				The Title

				Verse 1:
				Verse Content
				More Verse Content

				Bare
				More Bare

				(Verse 1)
				"""
			nl = Stream.cycle(["\n"])
			for i <- 0..4 do
				append = nl |> Stream.take(i) |> Enum.join()
				assert_parser_raw_data_results(song_contents <> append, {:ok, [
					{:title, "The Title"},
					{:named_verse, [{:verse_name, "Verse 1"}, "Verse Content", "More Verse Content"]},
					{:bare_verse, ["Bare", "More Bare"]},
					{:verse_ref, "Verse 1"}
				], "", %{}, {_, _}, _})
			end
		end

		test "parses song with arbitrary metadata" do
			"""
			The Title
			# this is sort of a comment, but it's really just bare metadata
			@default: Verse 1, Verse 1, Verse 1
			metadata1: this is some metadata
			background: https://placekitten.local/200/800
			and this is a bare metadata entry

			Verse 1:
			Verse Content
			More Verse Content

			Bare
			More Bare

			(Verse 1)
			"""
			|> assert_parser_raw_data_results({:ok, [
				{:title, "The Title"},
				{:metadata, [
					{:meta_bare, _},
					{:meta_named, ["@default", _]},
					{:meta_named, ["metadata1", "this is some metadata"]},
					{:meta_named, ["background", "https://placekitten.local/200/800"]},
					{:meta_bare, ["and this is a bare metadata entry"]},
				]},
				{:named_verse, [{:verse_name, "Verse 1"}, "Verse Content", "More Verse Content"]},
				{:bare_verse, ["Bare", "More Bare"]},
				{:verse_ref, "Verse 1"}
			], "", %{}, {_, _}, _})
		end
	end
end
