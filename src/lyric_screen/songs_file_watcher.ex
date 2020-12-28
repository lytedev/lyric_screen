defmodule LyricScreen.SongFileWatcher

{:ok, pid} = FileSystem.start_link(dirs: ["/path/to/some/files"])
FileSystem.subscribe(pid)
