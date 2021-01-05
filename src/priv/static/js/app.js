let csrfToken = document.querySelector('meta[name=csrf-token]').getAttribute('content')

let hooks = {
	editslidekey: {
		mounted() {
			console.log("editslidekey mounted")
			this.el.value = document.getElementById("edit_slide_key").value
		},
		destroyed() {},
	},
	editslidecontent: {
		mounted() {
			console.log("editslidecontent mounted")
			this.el.value = document.getElementById("edit_slide_content").value
		},
		destroyed() {},
	},
	addsongtype: {
		mounted() {
			this.el.addEventListener('click', (e) => {
				document.querySelector('input[name=add_song_type]').value = e.target.getAttribute('name')
			})
		},
		destroyed() {},
	},
	dragdrop: {
		mounted(a, b, c) {
			const hook = this
			console.log('drag_and_drop mounted', this, a, b, c)
			let s = new Sortable(this.el, {
				handle: '.handle',
				animation: 0,
				delay: 50,
				delayOnTouchOnly: true,
				group: this.el.dataset.group,
				draggable: '.draggable',
				ghostClass: 'draggable-ghost',
				onEnd: (ev) => {
					console.log(ev)
					hook.pushEventTo('#' + this.el.id, 'dropped', {
						old_at: parseInt(ev.item.attributes['draggable-index'].value),
						new_at: ev.newDraggableIndex,
						type: ev.to.id,
					})
				},
			})
			console.log(s)
		},
		destroyed() {
		},
	},
	focus: {
		mounted(a, b, c) {
			console.log('focus mounted', this, a, b, c)
			if ('select' in this.el) this.el.select()
		},
		destroyed() {},
	},
	root: {
		mounted() {},
		disconnected() {document.body.classList.add('phx-disconnected')},
		reconnected() {document.body.classList.remove('phx-disconnected')},
	}
}

let liveSocket = new Phoenix.LiveView.LiveSocket('/live', Phoenix.Socket, {
	hooks: hooks,
	params: {_csrf_token: csrfToken},
	metadata: {
    keydown: (e, el) => {
			console.log(e, el)
      return {
        key: e.key,
        shiftKey: e.shiftKey,
        altKey: e.altKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
				is_from_focusable: el.tagName == 'input',
        repeat: e.repeat
      }
    }
  }
})

topbar.config({barColors: {0: '#c4f'}, shadowColor: 'rgba(0, 0, 0, 0.3)'})
window.addEventListener('phx:page-loading-start', info => topbar.show())
window.addEventListener('phx:page-loading-stop', info => topbar.hide())

liveSocket.connect()

// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
// liveSocket.disableLatencySim()
