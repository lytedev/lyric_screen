defmodule LyricScreen.Web.Live.Clock do
	@moduledoc false

	use Phoenix.LiveView

	def render(assigns) do
		~L"""
		<div>
			<h2>It's <%= inspect(@date) %></h2>
			<%# live_render(@socket, DemoWeb.ImageLive, id: "image") %>
		</div>
		"""
	end

	def mount(_params, _session, socket) do
		if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

		{:ok, put_date(socket)}
	end

	def handle_info(:tick, socket) do
		{:noreply, put_date(socket)}
	end

	def handle_event("nav", _path, socket) do
		{:noreply, socket}
	end

	defp put_date(socket) do
		assign(socket, date: NaiveDateTime.local_now())
	end
end
