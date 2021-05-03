defmodule LyricScreen.Web.Live.Components.Modal do
  @moduledoc false

  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <%= if @adding_new_song? do %>
    	<div class="cover with-overlay flex flex-center" phx-submit="add_song" phx-change="suggest_song">
    		<div class="modal">
    			<header>
    				<span class="title">Add Existing Song to Playlist</span>
    			</header>
    			<form class="flex" phx-submit="add_song" phx-change="suggest_song">
    				<input id="song_searc_input" phx-hook="focus" class="flex-1" list="songs" name="song" autocomplete="off" />
    				<%# <input id="add_song_input" autofocus value="Add Song" type="submit" phx-hook="focus" /> %>

    				<datalist id="songs">
    					<%= for s <- @suggested_songs do %>
    						<option value="<%= s %>" />
    					<% end %>
    				</datalist>

    				<footer>
    					<input class="primary" type="submit" phx-click="add_song" value="Add" />
    					<button phx-click="cancel_add_song">Cancel</button>
    				</footer>
    			</form>
    		</div>
    		<button class="i cover-close" phx-click="cancel_add_song"><i class="material-icons">close</i></button>
    	</div>
    <% end %>
    """
  end
end
