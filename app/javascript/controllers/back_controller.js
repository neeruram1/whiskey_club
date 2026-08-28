import { Controller } from "@hotwired/stimulus"

// The installed app has no browser toolbar, so this is the only way back.
//
// Opening the app fresh from the home-screen icon starts an empty history
// stack, and so does landing on a tasting from a notification later — popping
// then would leave the app on a blank page, so fall back to a real URL.
export default class extends Controller {
  static values = { fallback: { type: String, default: "/" } }

  go(event) {
    event.preventDefault()

    if (window.history.length > 1) {
      window.history.back()
    } else {
      window.location.href = this.fallbackValue
    }
  }
}
