defmodule LyricScreen.User do
  use LyricScreen.Resource

  with_common_attributes do
    attribute :name, :string, allow_nil?: false, constraints: [max_length: 255]
  end

  relationships do
    has_many :songs, LyricScreen.User, destination_field: :user_id
  end
end
