defmodule LyricScreen.Repo.Migrations.AddSongsTables do
  use Ecto.Migration

  def change do
    create table("songs") do
      add :name, :string
      add :metadata, :map
      timestamps()
    end

    create index("songs", [:name])

    create table("verses") do
      add :song_id, references("songs")
      add :name, :string
      add :content, :string, size: 4096, default: ""
      timestamps()
    end

    create index("verses", [:content])
    create index("verses", [:song_id, :name], unique: true)

    create table("maps") do
      add :song_id, references("songs")
      add :name, :string
      timestamps()
    end

    create index("maps", [:song_id, :name], unique: true)

    create table("maps_verses") do
      add :map_id, references("maps")
      add :verse_id, references("verses")
      add :order, :integer, default: 0
      timestamps()
    end

    create index("maps_verses", [:map_id, :order])
  end
end
