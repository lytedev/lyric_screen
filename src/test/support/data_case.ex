defmodule LyricScreen.DataCase do
  use ExUnit.CaseTemplate

  @self __MODULE__

  using do
    quote do
      alias LyricScreen.Repo

      import Ecto
      import Ecto.Query
      import unquote(@self)
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(LyricScreen.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(LyricScreen.Repo, {:shared, self()})
    end

    :ok
  end
end
