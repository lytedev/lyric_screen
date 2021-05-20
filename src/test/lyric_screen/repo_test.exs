defmodule LyricScreen.RepoTest do
  use LyricScreen.RepoCase, async: true

  alias LyricScreen.Song
  alias LyricScreen.Repo

  describe "repo" do
    test "can select 1" do
      assert %Postgrex.Result{rows: [[1]]} = Repo.query!("select 1")
    end

    test "can insert and get a song" do
      {:ok, song} = LyricScreen.new_song(name: "My Song") |> IO.inspect()
      assert %Song{} = Repo.get(Song, song.id)
    end

    test "can insert and get a complex, nested song" do
      {:ok, song} = LyricScreen.new_song(name: "My Song") |> IO.inspect()
      assert %Song{} = Repo.preload(song, Song.preload_all())
    end
  end
end
