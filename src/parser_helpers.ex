defmodule LyricScreen.ParserHelpers do
	import NimbleParsec

	@ascii_newline 10

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
end

