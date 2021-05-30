defmodule LyricScreen.RepoTest do
  use LyricScreen.RepoCase, async: true

  alias Ash.Changeset
  alias LyricScreen.User
  alias LyricScreen.Api
  alias LyricScreen.Repo

  describe "repo" do
    test "can select 1" do
      assert %Postgrex.Result{rows: [[1]]} = Repo.query!("select 1")
    end

    test "can insert and get a user" do
      {:ok, song} = Api.create(Changeset.new(User, %{name: "user"}))
      assert %User{name: "user"} = Repo.get(User, song.id)
    end
  end
end
