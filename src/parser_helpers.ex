defmodule LyricScreen.ParserHelpers do
	@moduledoc """
	Provides general helpers and common combinators for parsers.
	"""

	import NimbleParsec

	@newline 10 # ascii newline \n char

	def s(c \\ empty()), do: c |> utf8_char([?\s, ?\t]) |> label("non-newline whitespace")
	def ws(c \\ empty()), do: c |> utf8_char([?\s, ?\n, ?\t, ?\r]) |> label("any whitespace")
	def eol(c \\ empty()), do: choice(c, [string("\r\n"), string("\n")]) |> label("newline")
	def eosl(c \\ empty()), do: choice(c, [eol(), eos()]) |> label("end of line or string")

	def non_empty_line(c \\ empty()) do
		c
		|> utf8_string([not: @newline], min: 1)
		|> ignore(eosl())
		|> label("non-empty line")
	end

	def empty_line(c \\ empty()) do
		c
		|> utf8_char([@newline])
		|> label("empty line")
	end

	def non_empty_line_chunk(c \\ empty()) do
		c
		|> times(non_empty_line(), min: 1)
		|> label("non-empty linechunk")
	end

	def trimmed_non_empty_line(c \\ empty()) do
		c
		|> ignore(repeat(s()))
		|> utf8_string([not: @newline], min: 1)
		|> ignore(repeat(s()))
		|> ignore(eosl())
		|> label("trimmed non-empty line")
	end

	def trimmed_non_empty_line_chunk(c \\ empty()) do
		c
		|> times(trimmed_non_empty_line(), min: 1)
		|> wrap()
		|> label("trimmed non-empty linechunk")
	end
end
