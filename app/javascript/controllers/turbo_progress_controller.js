import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Listen for Turbo events
    document.addEventListener("turbo:before-fetch-request", this.showProgress.bind(this))
    document.addEventListener("turbo:before-fetch-response", this.hideProgress.bind(this))
    document.addEventListener("turbo:submit-start", this.showProgress.bind(this))
    document.addEventListener("turbo:submit-end", this.hideProgress.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-fetch-request", this.showProgress.bind(this))
    document.removeEventListener("turbo:before-fetch-response", this.hideProgress.bind(this))
    document.removeEventListener("turbo:submit-start", this.showProgress.bind(this))
    document.removeEventListener("turbo:submit-end", this.hideProgress.bind(this))
  }

  showProgress() {
    this.element.style.opacity = "1"
    this.element.style.transform = "translateX(0%)"
    
    // Animate progress bar
    setTimeout(() => {
      this.element.style.transform = "translateX(70%)"
    }, 100)
  }

  hideProgress() {
    this.element.style.transform = "translateX(100%)"
    
    // Reset after animation
    setTimeout(() => {
      this.element.style.opacity = "0"
      this.element.style.transform = "translateX(-100%)"
    }, 300)
  }
}
