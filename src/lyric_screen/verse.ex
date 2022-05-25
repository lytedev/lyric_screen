defmodule LyricScreen.Verse do
  @moduledoc """
  The Map resource.
  """

  use LyricScreen.Resource

  postgres_table("verses")
  default_actions()

  attributes do
    ulid_primary_key(:id)
    attribute :name, :string, allow_nil?: true, constraints: [max_length: 255]
    attribute :name, :string, allow_nil?: true, constraints: [max_length: 255]
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :song, LyricScreen.Song, primary_key?: true, required?: true
    belongs_to :verse, LyricScreen.Verse, primary_key?: true, required?: true
  end

  identites do
  end
end
