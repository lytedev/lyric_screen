defmodule LyricScreen.MapVerse do
  @moduledoc """
  The Map resource.
  """

  use LyricScreen.Resource

  postgres_table("maps")
  default_actions()

  attributes do
    attribute :order, :integer, allow_nil?: false, default: 0
  end

  relationships do
    belongs_to :song, LyricScreen.Song, primary_key?: true, required?: true
    belongs_to :verse, LyricScreen.Verse, primary_key?: true, required?: true
  end
end
