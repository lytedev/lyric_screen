defmodule LyricScreen do
  @moduledoc """
  LyricScreen keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias LyricScreen.{Song,Repo}

  def new_song(opts \\ []) do
    opts
    |> Map.new()
    |> Song.new()
    |> Repo.insert()
  end
end
