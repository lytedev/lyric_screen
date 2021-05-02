defmodule LyricScreen.Repo.Migrations.Init do
  use Ecto.Migration
  def change, do: execute("select 1", "select 1")
end
