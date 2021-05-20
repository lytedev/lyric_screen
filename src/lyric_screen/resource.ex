defmodule LyricScreen.Resource do
  use Ash.Resource

  defmacro with_common_attributes(do: body) do
    quote do
      uuid_primary_key :id
      unquote(body)
      create_timestamp :inserted_at
      update_timestamp :updated_at
    end
  end
end
