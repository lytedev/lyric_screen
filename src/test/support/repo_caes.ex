defmodule LyricScreen.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias LyricScreen.Repo

      import Ecto
      import Ecto.Query
      import LyricScreen.RepoCase
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
