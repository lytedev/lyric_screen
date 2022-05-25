defmodule LyricScreen.Map do
  @moduledoc """
  The Map resource.
  """

  use LyricScreen.Resource

  postgres_table("maps")
  default_actions()

  attributes do
    ulid_primary_key(:id)
    attribute :name, :string, allow_nil?: false, constraints: [max_length: 255]
    attribute :metadata, :map, allow_nil?: false, default: %{}
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :song, LyricScreen.Song
    has_many :verses, LyricScreen.MapVerse
  end
end
