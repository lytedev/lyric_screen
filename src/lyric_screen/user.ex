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

  defmodule Email do
    use LyricScreen.Resource

    postgres_table("user_emails")
    default_actions()

    attributes do
      attribute :email, :string do
        allow_nil? false
        primary_key? true
        constraints max_length: 1024
      end

      create_timestamp :inserted_at
      update_timestamp :updated_at
    end

    relationships do
      # has_many :songs, LyricScreen.User, destination_field: :user_id
    end
  end

  defmodule Account do
  end
end
