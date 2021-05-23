defmodule LyricScreen.Ash.Type.UXID do
	use Ash.Type

	# TODO: prefixing and unprefixing needed
	# TODO: how does a using module set the prefix?

	@impl Ash.Type
	def storage_type, do: :uuid

	@impl Ash.Type
	def cast_input(value, _), do: Ecto.Type.cast(:uuid, value)

	@impl Ash.Type
	def cast_stored(value, _), do: Ecto.Type.load(:uuid, value)

	@impl Ash.Type
	def dump_to_native(value, _), do: Ecto.Type.dump(:uuid, value)
end
