defmodule LyricScreen.Api do
  use Ash.Api

  resources do
    resource LyricScreen.User
    resource LyricScreen.Song
    resource LyricScreen.Display
  end
end
