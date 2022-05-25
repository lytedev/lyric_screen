defmodule LyricScreen.DataTest do
  use LyricScreen.DataCase, async: true

  alias LyricScreen.Repo

  describe "repo" do
    test "can select 1" do
      assert %Postgrex.Result{rows: [[1]]} = Repo.query!("select 1")
    end
  end
end
