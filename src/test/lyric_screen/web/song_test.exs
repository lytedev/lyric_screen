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

	# TODO: property tests...?

	describe "parser" do
		test "does not error on whatever corpus exists - parser should be resilient to input" do
			assert nil == LyricScreen.Song.File.all_data() |> Enum.find(fn {_key, {result, _data}} -> result == :error end)
		end

		test "fails to parse empty song data" do
			assert_parser_raw_data_results("", {:error, _, _, %{}, {_, _}, _})
		end

		test "fails to parse songs without a title as the first line" do
			assert_parser_raw_data_results("\n", {:error, _, _, %{}, {_, _}, _})
			assert_parser_raw_data_results("\nSong Title", {:error, _, _, %{}, {_, _}, _})
		end

		test "parses simplest possible song" do
			assert_parser_raw_data_results("a", {:ok, [title: "a", verses: []], "", %{}, {_, _}, _})
		end

		test "parses simple song with one verse" do
			assert_parser_raw_data_results("a\n\na", {:ok, [title: "a", verses: [{:bare_verse, ["a"]}]], "", _, _, _})
		end

		test "parses almost-ref-verses" do
			assert_parser_raw_data_results("a\n\n(a)\na", {:ok, [title: "a", verses: [{:bare_verse, ["(a)", "a"]}]], "", %{}, {_, _}, _})
		end

		test "parses botched ref-verse" do
			assert_parser_raw_data_results("a\n\n(a\na", {:ok, [title: "a", verses: [{:bare_verse, ["(a", "a"]}]], "", %{}, {_, _}, _})
			assert_parser_raw_data_results("a\n\n(a)a\na", {:ok, [title: "a", verses: [{:bare_verse, ["(a)a", "a"]}]], "", %{}, {_, _}, _})
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
					title: "The Title",
					verses: [
						{:named_verse, [{:verse_name, "Verse 1"}, "Verse Content", "More Verse Content"]},
						{:bare_verse, ["Bare", "More Bare"]},
						{:verse_ref, "Verse 1"},
					],
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
				title: "The Title",
				metadata: [
					{:meta_bare, _},
					{:meta_named, ["@default", _]},
					{:meta_named, ["metadata1", "this is some metadata"]},
					{:meta_named, ["background", "https://placekitten.local/200/800"]},
					{:meta_bare, ["and this is a bare metadata entry"]},
				],
				verses: [
					{:named_verse, [{:verse_name, "Verse 1"}, "Verse Content", "More Verse Content"]},
					{:bare_verse, ["Bare", "More Bare"]},
					{:verse_ref, "Verse 1"}
				],
			], "", %{}, {_, _}, _})
		end

		test "parses basic song with a different structure/order" do
			song_contents =
				"""
				The Title
				meta: data

				Bare
				More Bare

				(Verse 1)

				Verse 1:
				Verse Content
				More Verse Content
				"""
			nl = Stream.cycle(["\n"])
			for i <- 0..4 do
				append = nl |> Stream.take(i) |> Enum.join()
				assert_parser_raw_data_results(song_contents <> append, {:ok, [
					title: "The Title",
					metadata: [meta_named: ["meta", "data"]],
					verses: [
						{:bare_verse, ["Bare", "More Bare"]},
						{:verse_ref, "Verse 1"},
						{:named_verse, [{:verse_name, "Verse 1"}, "Verse Content", "More Verse Content"]},
					],
				], "", %{}, {_, _}, _})
			end
		end

		test "parses song ending with a ref verse" do
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

			(Verse 1)\s


			"""
			|> assert_parser_raw_data_results({:ok, [
				title: "The Title",
				metadata: [
					{:meta_bare, _},
					{:meta_named, ["@default", _]},
					{:meta_named, ["metadata1", "this is some metadata"]},
					{:meta_named, ["background", "https://placekitten.local/200/800"]},
					{:meta_bare, ["and this is a bare metadata entry"]},
				],
				verses: [
					{:named_verse, [{:verse_name, "Verse 1"}, "Verse Content", "More Verse Content"]},
					{:bare_verse, ["Bare", "More Bare"]},
					{:verse_ref, "Verse 1"},
					{:verse_ref, "Verse 1"}
				],
			], "", %{}, {_, _}, _})
		end

		test "parses song ending with a mixing of ref verses" do
			"""
			Song
			meta: mm

			v1a:
			v1a

			v1b:
			v1b

			Pre-Chorus:
			pc

			Chorus:
			ch

			v2a:
			v2a

			v2b:
			v2b

			(Pre-Chorus)

			(Chorus)

			Tag:
			ttyl

			(Tag)

			(Chorus)

			(Pre-Chorus)

			(Chorus)
			"""
			|> assert_parser_raw_data_results({:ok, [
				title: "Song",
				metadata: [
					{:meta_named, ["meta", "mm"]},
				],
				verses: [
					{:named_verse, [{:verse_name, "v1a"}, "v1a"]},
					{:named_verse, [{:verse_name, "v1b"}, "v1b"]},
					{:named_verse, [{:verse_name, "Pre-Chorus"}, "pc"]},
					{:named_verse, [{:verse_name, "Chorus"}, "ch"]},
					{:named_verse, [{:verse_name, "v2a"}, "v2a"]},
					{:named_verse, [{:verse_name, "v2b"}, "v2b"]},
					{:verse_ref, "Pre-Chorus"},
					{:verse_ref, "Chorus"},
					{:named_verse, [{:verse_name, "Tag"}, "ttyl"]},
					{:verse_ref, "Tag"},
					{:verse_ref, "Chorus"},
					{:verse_ref, "Pre-Chorus"},
					{:verse_ref, "Chorus"},
				],
			], "", %{}, {_, _}, _})
		end
	end
end
