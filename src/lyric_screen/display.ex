defmodule LyricScreen.Display do
  use LyricScreen.Schema

  alias LyricScreen.Playlist

  schema "displays" do
    field(:name, :string)

    belongs_to(:playlist, Playlist)

    field(:song_index, :integer, null: true, default: nil)
    field(:slide_index, :integer, null: true, default: nil)

    field(:frozen_song_index, :integer, null: true, default: nil)
    field(:frozen_slide_index, :integer, null: true, default: nil)

    field(:visible, :boolean, default: true)
  end

  @required_fields []
  @optional_fields [
    :playlist_id,
    :song_index,
    :slide_index,
    :frozen_song_index,
    :frozen_slide_index,
    :visible
  ]

  def changeset(display \\ %__MODULE__{}, params \\ %{}) do
    display
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(params, @required_fields)
    |> maybe_validate_playlist()

    # TODO: validations for song/slide indexes, must be valid (point to actual data) or nil
  end

  defp maybe_validate_playlist(changeset) do
    IO.inspect(changeset)
  end
end
