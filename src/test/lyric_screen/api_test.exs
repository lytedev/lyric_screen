defmodule LyricScreen.ApiTest do
  use LyricScreen.DataCase, async: true

  alias Ash.Changeset
  alias LyricScreen.User
  alias LyricScreen.Api
  alias LyricScreen.Repo

  describe "api" do
    test "can insert and get a user" do
      {:ok, song} = Api.create(Changeset.new(User, %{name: "user"}))
      assert %User{name: "user"} = Repo.get(User, song.id)
    end
  end
end
