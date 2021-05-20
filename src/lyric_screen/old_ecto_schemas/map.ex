defmodule LyricScreen.Map do
  use LyricScreen.Schema
  alias LyricScreen.Map.Entry

  schema "maps" do
    belongs_to :song, LyricScreen.Song
    field :name, :string
    has_many :entries, Entry
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

  defmodule Entry do
    use LyricScreen.Schema

    schema "map_verses" do
      belongs_to :verse, LyricScreen.Verse
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
end
