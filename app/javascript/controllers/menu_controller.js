import { Controller } from "@hotwired/stimulus"

// Toggles the mobile navigation menu, keeping aria-expanded in sync and
// closing on Escape or an outside click for keyboard/screen-reader users.
export default class extends Controller {
  static targets = ["panel", "button"]

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    if (!this.isOpen) return
    this.panelTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  get isOpen() {
    return !this.panelTarget.classList.contains("hidden")
  }
}
