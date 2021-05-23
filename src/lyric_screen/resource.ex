defmodule LyricScreen.Resource do
  defmacro __using__(opts) do
    quote do
      use Ash.Resource, unquote(opts)

      import LyricScreen.Resource
    end
  end

  defmacro ulid_primary_key(key \\ :id) do
    quote do
      attribute unquote(key), LyricScreen.Ash.Type.ULID do
        primary_key? true
        writable? false
        default Ecto.ULID.bingenerate()
        allow_nil? false
      end
    end
  end

  defmacro uxid_primary_key(key \\ :id) do
    quote do
      attribute unquote(key), LyricScreen.Ash.Type.UXID do
        primary_key? true
        writable? false
        default LyricScreen.UXID.bingenerate()
        allow_nil? false
      end
    end
  end
end
