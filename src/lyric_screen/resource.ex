defmodule LyricScreen.Resource do
  defmacro __using__(opts) do
    opts = Keyword.put_new(opts, :data_layer, AshPostgres.DataLayer)

    quote do
      use Ash.Resource, unquote(opts)
      import LyricScreen.Resource
    end
  end

  defmacro postgres_table(name) do
    quote do
      postgres do
        repo(LyricScreen.Repo)
        table unquote(name)
      end
    end
  end

  defmacro default_actions() do
    quote do
      actions do
        create :create
        read :read
        update :update
        destroy :destroy
      end
    end
  end

  defmacro ulid_primary_key(key \\ :id) do
    quote do
      attribute unquote(key), LyricScreen.Ash.Type.ULID do
        primary_key? true
        writable? false
        default &Ecto.ULID.bingenerate/0
        allow_nil? false
      end
    end
  end

  defmacro uxid_primary_key(key \\ :id) do
    quote do
      attribute unquote(key), LyricScreen.Ash.Type.UXID do
        primary_key? true
        writable? false
        default &LyricScreen.UXID.bingenerate/0
        allow_nil? false
      end
    end
  end
end
