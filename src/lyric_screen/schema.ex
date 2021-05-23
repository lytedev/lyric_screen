defmodule LyricScreen.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key {:id, Ecto.ULID, autogenerate: true}
      @foreign_key_type Ecto.ULID

      def new(params), do: changeset(%__MODULE__{}, Map.new(params))

      def base_changeset(song \\ %__MODULE__{}, params \\ %{})

      def base_changeset(params, base) do
        base
        |> cast(params, @required_fields ++ @optional_fields)
        |> validate_required(@required_fields)
      end
    end
  end
end
