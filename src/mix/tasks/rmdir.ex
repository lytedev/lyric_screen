defmodule Mix.Tasks.Rmdir do
  use Mix.Task

  @impl Mix.Task
  def run(opts)
	def run([dir]) do
		File.rm_rf!(dir)
		IO.puts("Removed #{dir}")
	end
  def run(_), do: raise("no dir specified")
end
