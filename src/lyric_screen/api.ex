defmodule LyricScreen.Api do
  use Ash.Api

  resources do
    resource LyricScreen.User
    resource LyricScreen.Song
    resource LyricScreen.Map
    resource LyricScreen.Verse
    resource LyricScreen.Display
    resource LyricScreen.MapVerse
  end
end
