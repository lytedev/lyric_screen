defmodule LyricScreen.Playlist do
  @moduledoc false

  use LyricScreen.Schema

  alias LyricScreen.Playlist
  alias LyricScreen.PlaylistSong
  alias LyricScreen.Song

  schema "playlist" do
    field :name, :string
    many_to_many :songs, Song, join_through: PlaylistSong
  end

  @required_fields [:name]
  @optional_fields [:songs]

  def changeset(playlist_song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = playlist, params) do
    playlist
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(params, @required_fields)

    # TODO: cast_assoc songs?
  end
end

defmodule LyricScreen.PlaylistSong do
  @moduledoc false

  use LyricScreen.Schema

  alias LyricScreen.Playlist
  alias LyricScreen.Song

  schema "playlist_songs" do
    belongs_to :playlist, Playlist
    belongs_to :song, Song
    field :order, :integer, default: 0
  end

  @required_fields [:playlist_id, :song_id]
  @optional_fields [:order]

  def changeset(playlist_song \\ %__MODULE__{}, params \\ %{})

  def changeset(%__MODULE__{} = playlist_song, params) do
    playlist_song
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(params, @required_fields)
    |> foreign_key_constraint([:playlist_id, :song_id])

    # TODO: default should add to the end of the playlist (max current order plus 1)
  end
end
