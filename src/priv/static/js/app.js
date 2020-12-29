let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let hooks = {
	dragdrop: {
		mounted(a, b, c) {
			const hook = this
			console.log("drag_and_drop mounted", this, a, b, c)
			new Sortable(this.el, {
				animation: 0,
				delay: 50,
				delayOnTouchOnly: true,
				group: this.el.dataset.group,
				draggable: '.draggable',
				ghostClass: 'draggable-ghost',
				onEnd: (ev) => {
					console.log(ev)
					hook.pushEventTo('#' + this.el.id, 'dropped', {
						old_at: parseInt(ev.item.attributes["draggable-index"].value),
						new_at: ev.newDraggableIndex,
						type: ev.to.id,
					});
				},
			});
		},
	},
	focus: {
		mounted(a, b, c) {
			console.log("focus mounted", this, a, b, c)
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
