defmodule LyricScreen.Web.Router do
	use LyricScreen.Web, :router

	pipeline :browser do
		plug :accepts, ["html"]
		plug :fetch_session
		# plug :fetch_flash
		plug :put_root_layout, {LyricScreen.Web.LayoutView, :root}
		plug :fetch_live_flash
		plug :protect_from_forgery
		plug :put_secure_browser_headers
	end

	pipeline :api do
		plug :accepts, ["json"]
	end

	scope "/", LyricScreen.Web do
		pipe_through :browser

		get "/", PageController, :index
		get "/status", PageController, :status
		live "/clock", Live.Clock
		live "/dashboard", Live.Dashboard
		get "/display/controls/:id", DisplayController, :show_control_panel
		get "/display/:id", DisplayController, :show_basic_lyrics
	end

	# Other scopes may use custom stacks.
	# scope "/api", LyricScreen.Web do
	#	 pipe_through :api
	# end

	# Enables LiveDashboard only for development
	#
	# If you want to use the LiveDashboard in production, you should put
	# it behind authentication and allow only admins to access it.
	# If your application does not have an admins-only section yet,
	# you can use Plug.BasicAuth to set up some basic authentication
	# as long as you are also using SSL (which you should anyway).
	if Mix.env() in [:dev, :test] do
		import Phoenix.LiveDashboard.Router

		scope "/admin" do
			pipe_through :browser
			live_dashboard "/live-dashboard", metrics: LyricScreen.Web.Telemetry
		end
	end
end
