defmodule LyricScreen.Song do
  alias LyricScreen.SongVerse
  alias LyricScreen.SongMap

  use LyricScreen.Schema

  require Logger

  schema "songs" do
    field :name, :string
    field :metadata, :map, default: %{}
    has_many :verses, SongVerse
    has_many :maps, SongMap
  end
end

defmodule LyricScreen.SongVerse do
  @moduledoc """
  Defines the struct for a verse in a song.
  """

  use LyricScreen.Schema
  alias LyricScreen.Song

  schema "song_verses" do
    belongs_to :song, Song
    field :type, Ecto.Enum, values: [:bare, :ref, :named], default: :bare
    field :content, :string, default: "", null: true
  end

  @required_fields [:song_id, :type]
  @optional_fields [:content]

  def changeset(playlist_song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song_verse, params) do
    song_verse
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(params, @required_fields)
    |> foreign_key_constraint([:song_id])

    # TODO: verify content with type (if bare, should not be nil, etc.
  end
end

defmodule LyricScreen.SongMap do
  use LyricScreen.Schema
  alias LyricScreen.MapEntry

  schema "song_maps" do
    belongs_to :song, Song
    has_many :entries, MapEntry
  end

  @required_fields [:song_id]
  @optional_fields []

  def changeset(song_map \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song_map, params) do
    song_map
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(params, @required_fields)
    |> foreign_key_constraint([:song_id])

    # TODO: default should add to the end of the playlist (max current order plus 1)
  end
end

defmodule LyricScreen.MapEntry do
  use LyricScreen.Schema

  schema "song_maps" do
    belongs_to :verse, Song
    field :order, :integer, default: 0
  end

  def changeset(map_entry \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = map_entry, params) do
    map_entry
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(params, @required_fields)
    |> foreign_key_constraint([:song_id])

    # TODO: default should add to the end of the playlist (max current order plus 1)
  end
end
