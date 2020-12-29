defmodule LyricScreen.ParserHelpers do
	@moduledoc """
	Provides general helpers and common combinators for parsers.
	"""

	import NimbleParsec

	@ascii_newline 10

	def s(c \\ empty()), do: ascii_char([?\s, ?\t])
	def ws(c \\ empty()), do: ascii_char([?\s, ?\n, ?\t, ?\r])
	def eol(c \\ empty()), do: choice(c, [string("\r\n"), string("\n")])
	def eosl(c \\ empty()), do: choice(c, [eol(), eos()])

	def non_empty_line(c \\ empty()) do
		c
		|> ascii_string([not: @ascii_newline], min: 1)
		|> ignore(eosl())
		|> label("non-empty line")
	end

	def empty_line(c \\ empty()) do
		c
		|> ascii_char([@ascii_newline])
		|> label("empty line")
	end

	def non_empty_line_chunk(c \\ empty()) do
		c
		|> times(non_empty_line(), min: 1)
		|> wrap()
		|> label("non-empty linechunk")
	end

	def trimmed_non_empty_line(c \\ empty()) do
		c
		|> ignore(repeat(s()))
		|> non_empty_line()
		|> ignore(repeat(s()))
		|> label("trimmed non-empty line")
	end

	def trimmed_non_empty_line_chunk(c \\ empty()) do
		c
		|> times(trimmed_non_empty_line(), min: 1)
		|> wrap()
		|> label("trimmed non-empty linechunk")
	end
end
