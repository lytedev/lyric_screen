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
    timestamps()
  end

  @required_fields [:name]
  @optional_fields [:metadata]

  def new(params) do
    %__MODULE__{}
    |> changeset(Map.new(params))
    |> Repo.insert()
  end

  def new(params), do: changeset(%__MODULE__{}, Map.new(params))

  def changeset(song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song, params) do
    song
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:song_id)
  end

  def preload_all(), do: [:verses, maps: [entries: [:verses]]]
end

defmodule LyricScreen.SongVerse do
  @moduledoc """
  Defines the struct for a verse in a song.
  """

  use LyricScreen.Schema
  alias LyricScreen.Song

  schema "song_verses" do
    belongs_to :song, Song
    field :name, :string
    field :content, :string, default: ""
    timestamps()
  end

  @required_fields [:song_id, :name]
  @optional_fields [:content]

  def new(params), do: changeset(%__MODULE__{}, Map.new(params))

  def changeset(playlist_song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song_verse, params) do
    song_verse
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:song_id)
  end
end

defmodule LyricScreen.SongMap do
  use LyricScreen.Schema
  alias LyricScreen.MapEntry

  schema "song_maps" do
    belongs_to :song, Song
    field :name, :string
    has_many :entries, MapEntry
    timestamps()
  end

  @required_fields [:song_id, :name]
  @optional_fields []

  def changeset(song_map \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = song_map, params) do
    song_map
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:song_id)

    # TODO: default should add to the end of the playlist (max current order plus 1)
  end
end

defmodule LyricScreen.MapEntry do
  use LyricScreen.Schema

  schema "song_map_entries" do
    belongs_to :verse, Song
    field :order, :integer, default: 0
    timestamps()
  end

  @required_fields [:map_id, :verse_id]
  @optional_fields [:order]

  def changeset(map_entry \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = map_entry, params) do
    map_entry
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:song_id)

    # TODO: default should add to the end of the playlist (max current order plus 1)
  end
end
