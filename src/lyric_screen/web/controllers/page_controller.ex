defmodule LyricScreen.Web.PageController do
	use LyricScreen.Web, :controller

	def index(conn, _params) do
		render(conn, "index.html")
	end
end
