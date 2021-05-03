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
    # ignore whitespace following delim
    |> ignore(repeat(ws()))
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

  verse =
    choice([named_verse, ref_verse, bare_verse])
    |> ignore(choice([times(empty_line(), min: 1), eos()]))

  defparsec(
    :raw_data,
    title
    |> optional(metadata)
    |> ignore(repeat(empty_line()))
    |> optional(
      repeat(verse)
      |> tag(:verses)
    )
    |> ignore(repeat(empty_line()))
    |> ignore(eos())
  )
end
