defmodule LyricScreen.Chat.File do
	@moduledoc false

	def dir, do: Application.get_env(:lyric_screen, :chats_dir)

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
end

defmodule LyricScreen.Chat do
	@moduledoc false

	# use Phoenix.Channel
	def add_message(_chat, _from, _content) do
	end

	def load_history(_chat) do
	end

	def clear_chat(_chat) do
	end
end
