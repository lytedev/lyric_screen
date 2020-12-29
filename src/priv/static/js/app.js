let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let hooks = {
	focus: {
		mounted(a, b, c) {
			console.log("mounted", this, a, b, c)
			if ("select" in this.el) this.el.select()
		},
		destroyed() {},
	}
}

let liveSocket = new Phoenix.LiveView.LiveSocket("/live", Phoenix.Socket, {hooks: hooks, params: {_csrf_token: csrfToken}})

topbar.config({barColors: {0: "#c4f"}, shadowColor: "rgba(0, 0, 0, 0.3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

liveSocket.connect()

// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
// liveSocket.disableLatencySim()
