// Registers the service worker that makes the club installable on a phone.
// Kept to registration only — the caching rules live in the worker itself.
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js").catch((error) => {
      // A failed registration costs the offline fallback, not the app, so log
      // and move on rather than breaking the page.
      console.error("Service worker registration failed:", error)
    })
  })
}
