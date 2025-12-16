import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    console.log("archive-toggle connected")
    this.show("bottles")
  }

  switch(event) {
    event.preventDefault()
    this.show(event.currentTarget.dataset.view)
  }

  show(view) {
    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.view !== view)
    })

    this.tabTargets.forEach(tab => {
      const active = tab.dataset.view === view
      tab.classList.toggle("text-lagavulin-gold", active)
      tab.classList.toggle("border-lagavulin-gold/70", active)
      tab.classList.toggle("text-[#E8D6A7]/70", !active)
      tab.classList.toggle("border-transparent", !active)
    })
  }
}
