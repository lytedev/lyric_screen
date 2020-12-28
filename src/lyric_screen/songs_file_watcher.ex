defmodule LyricScreen.SongFileWatcher do
	@moduledoc false

	use Task

	def start_link(_, _) do
		{:ok, pid} = FileSystem.start_link(dirs: ["/path/to/some/files"])
		FileSystem.subscribe(pid)
	end
end
