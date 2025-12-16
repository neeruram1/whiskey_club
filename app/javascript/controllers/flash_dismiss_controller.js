import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss after 5 seconds for notices, 8 seconds for errors
    const isError = this.element.classList.contains('flash-red')
    const delay = isError ? 8000 : 5000
    
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, delay)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Fade out animation
    this.element.style.opacity = '0'
    this.element.style.transform = 'translateY(-1rem)'
    this.element.style.transition = 'opacity 300ms ease, transform 300ms ease'
    
    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
