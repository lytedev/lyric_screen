defmodule LyricScreen.Song do
  require Logger

  alias LyricScreen.SongVerse
  alias LyricScreen.SongMap

  @required_fields [:name]
  @optional_fields [:metadata]

  use LyricScreen.Schema

  schema "songs" do
    field :name, :string
    field :metadata, :map, default: %{}
    has_many :verses, SongVerse
    has_many :maps, SongMap
    timestamps()
  end

  def changeset(song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song, params) do
    params
    |> base_changeset(song)
    |> foreign_key_constraint(:song_id)
  end

  def preload_all(), do: [:verses, maps: [entries: [:verses]]]
end
