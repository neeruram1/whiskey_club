import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Prevent Turbo from navigating away when frame is missing
    document.addEventListener('turbo:frame-missing', this.handleFrameMissing)
  }

  disconnect() {
    document.removeEventListener('turbo:frame-missing', this.handleFrameMissing)
  }

  handleFrameMissing(event) {
    event.preventDefault()
  }

  close(event) {
    event?.preventDefault()
    // Find and remove the turbo frame content
    const frame = document.getElementById("modal")
    if (frame) {
      frame.src = null
      frame.removeAttribute("src")
      frame.innerHTML = ""
    }
  }

  closeBackground(event) {
    // Only close if clicking the backdrop, not the modal content
    if (event.target === event.currentTarget) {
      this.close(event)
    }
  }
  
  stopPropagation(event) {
    event.stopPropagation()
  }
}
