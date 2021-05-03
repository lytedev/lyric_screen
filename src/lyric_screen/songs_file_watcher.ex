defmodule LyricScreen.SongFileWatcher do
  @moduledoc false

  use Task

  require Logger

  def start_link(args) do
    Task.start_link(__MODULE__, :run, List.wrap(args))
  end

  def run(_args) do
    {:ok, pid} = FileSystem.start_link(dirs: ["src/priv/data/songs/"])
    FileSystem.subscribe(pid)
  end

  def handle_info(
        {:file_event, watcher_pid, {_path, _events}} = ev,
        %{watcher_pid: watcher_pid} = state
      ) do
    Logger.warn(inspect({ev, state}))
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop} = ev, %{watcher_pid: watcher_pid} = state) do
    Logger.error(inspect({ev, state}))
    {:noreply, state}
  end
end
