import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  open(event) {
    const clickedFrameId = event.currentTarget.dataset.archivePeekFrameIdValue
    if (!clickedFrameId) return

    // Close any other open frames by reloading them as row state
    const frames = this.listTarget.querySelectorAll("turbo-frame[id^='bottle_']")
    frames.forEach(frame => {
      if (frame.id === clickedFrameId) return

      const bottleId = frame.id.replace("bottle_", "")
      const url = `/bottles/${bottleId}?peek=0`
      frame.src = url
      frame.reload()
    })
  }
}
