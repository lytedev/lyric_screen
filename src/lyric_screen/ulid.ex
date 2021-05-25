defmodule LyricScreen.Ash.Type.ULID do
  use Ash.Type

  @impl Ash.Type
  def storage_type, do: :uuid

  @impl Ash.Type
  def cast_input(value, _), do: Ecto.Type.cast(Ecto.UUID, value)

  @impl Ash.Type
  def cast_stored(value, _), do: Ecto.Type.load(Ecto.UUID, value)

  @impl Ash.Type
  def dump_to_native(value, _), do: Ecto.Type.dump(Ecto.UUID, value)
end
