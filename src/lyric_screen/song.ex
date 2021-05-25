defmodule LyricScreen.Song do
  @moduledoc """
  The Song resource.
  """

  use LyricScreen.Resource

  postgres_table("songs")
  default_actions()

  attributes do
    ulid_primary_key :id
    attribute :name, :string, allow_nil?: false, constraints: [max_length: 255]
    attribute :metadata, :map, allow_nil?: false, default: %{}
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    # belongs_to :user, LyricScreen.User
    # has_many :verses, LyricScreen.Verse, destination_field: :song_id
    # has_many :maps, LyricScreen.Map, destination_field: :song_id
  end
end
