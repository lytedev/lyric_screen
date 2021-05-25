defmodule LyricScreen.User do
  use LyricScreen.Resource

  postgres_table("users")
  default_actions()

  attributes do
    ulid_primary_key(:id)
    attribute :name, :string, allow_nil?: false, constraints: [max_length: 255]
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    # has_many :songs, LyricScreen.User, destination_field: :user_id
  end
end
