defmodule LyricScreen.Display do
  @moduledoc """
  The Song resource.
  """

  use LyricScreen.Resource

  attributes do
    ulid_primary_key :id
    attribute :name, :string, allow_nil?: false, constraints: [max_length: 255]
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
  end
end
