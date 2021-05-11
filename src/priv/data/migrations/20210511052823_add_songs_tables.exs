defmodule LyricScreen.Repo.Migrations.AddSongsTables do
  use Ecto.Migration

  def change do
    create table("songs") do
      add :name, :string
      add :metadata, :map
      timestamps()
    end

    create index("songs", [:name])

    create table("song_verses") do
      add :song_id, references("songs")
      add :name, :string
      add :content, :string, size: 4096, default: ""
      timestamps()
    end

    create index("song_verses", [:content])
    create index("song_verses", [:song_id, :name], unique: true)

    create table("song_maps") do
      add :song_id, references("songs")
      add :name, :string
      timestamps()
    end

    create index("song_maps", [:song_id, :name], unique: true)

    create table("maps_verses") do
      add :map_id, references("song_maps")
      add :verse_id, references("song_verses")
      add :order, :integer, default: 0
      timestamps()
    end

    create index("song_map_verses", [:map_id, :order])
  end
end
