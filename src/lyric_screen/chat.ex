defmodule LyricScreen.Chat.File do
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
	use Phoenix.Channel
	def add_message(chat, from, content) do
	end

	def load_history(chat) do
	end

	def clear_chat(chat) do
	end
end
