defmodule LyricScreen.Display.File do
	def dir, do: Application.get_env(:lyric_screen, :displays_dir)

	defp valid_file?(f) do
		String.ends_with?(f, ".txt")
	end

	def ls do
		case File.ls(dir()) do
			{:ok, files} ->
				keys =
					files
					|> Enum.filter(&valid_file?/1)
					|> Enum.map(&(String.trim_trailing(&1, ".txt")))
				{:ok, keys}
			{:error, _reason} = err -> err
		end
	end

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

	def parse(str) do
		case :erlang.binary_to_term(str) do
			%{} = display -> {:ok, display}
			err -> {:error, err}
		end
	end

	def parse_file(f) do
		case content(f) do
			{:ok, content} -> parse(content)
			err -> {:error, err}
		end
	rescue
		err -> {:error, err}
	end
end

defmodule LyricScreen.Display do
	alias LyricScreen.Display.File, as: F

	defstruct [
		key: nil,
		playlist: "default",
		current_song_index: 0,
		current_slide_index: 0,
		frozen?: false,
		hidden?: false,
	]

	def load_from_file(f), do: F.parse_file(f)
	def save_to_file(%__MODULE__{key: key} = display) do
		:ok = File.write(Path.join(F.dir(), key <> ".txt"), :erlang.term_to_binary(display))
		{:ok, display}
	end

	def set_current_song_index(%__MODULE__{} = display, index), do: %{display | current_song_index: index} |> save_to_file()
	def set_current_slide_index(%__MODULE__{} = display, index), do: %{display | current_slide_index: index} |> save_to_file()
	def set_playlist(%__MODULE__{} = display, p), do: %{display | playlist: p} |> save_to_file()
end
