defmodule LyricScreen.RepoTest do
  use LyricScreen.RepoCase, async: true

  alias LyricScreen.Repo
  alias LyricScreen.Song

  describe "repo" do
    test "can select 1" do
      assert %Postgrex.Result{rows: [[1]]} = Repo.query!("select 1")
    end

    test "can insert and get a song" do
      song =
        Repo.insert!(Song.new(name: "My Song") |> IO.inspect())

      assert %Song{} = Repo.get(Song, song.id)
    end

    test "can insert and get a complex, nested song" do
      song = Repo.insert!(Song.new(name: "My Song", map))
        |> IO.inspect()

      assert %Song{} =
               Song
               |> Repo.preload(Song.preload_all())
    end
  end
end
