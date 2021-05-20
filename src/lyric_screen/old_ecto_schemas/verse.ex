defmodule LyricScreen.Verse do
  @moduledoc """
  Defines the struct for a verse in a song.
  """

  alias LyricScreen.Song

  @required_fields [:song_id, :name]
  @optional_fields [:content]

  use LyricScreen.Schema

  schema "verses" do
    belongs_to :song, Song
    field :name, :string
    field :content, :string, default: ""
    timestamps()
  end

  def new(params), do: changeset(%__MODULE__{}, Map.new(params))

  def changeset(playlist_song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song_verse, params) do
    song_verse
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:song_id)
  end
end
