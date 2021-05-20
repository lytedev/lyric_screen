defmodule LyricScreen.Song do
  use LyricScreen.Resource

  with_common_attributes do
    attribute :name, :string, allow_nil?: false, constraints: [max_length: 255]
    attribute :metadata, :map, allow_nil?: false, default: %{}
  end

  relationships do
    belongs_to :user, LyricScreen.User
    has_many :verses, LyricScreen.Verse, destination_field: :song_id
    has_many :maps, LyricScreen.Map, destination_field: :song_id
  end
end
