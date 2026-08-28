# Serves the installable-app plumbing: the manifest, the service worker, and the
# offline fallback page. All three are fetched by the browser itself — sometimes
# with no session attached — so they skip authentication. Nothing here touches
# club data; the manifest and worker are the same for every member.
class PwaController < ApplicationController
  skip_before_action :authenticate_user!

  # Rails blocks cross-origin <script> embedding by rejecting non-XHR GETs that
  # respond as JavaScript — which is exactly how a browser fetches a service
  # worker. These three actions are GET-only and read no state, so there's
  # nothing for forgery protection to guard.
  skip_forgery_protection

  # Templates live in app/views/pwa. They're ERB so they can use asset_path and
  # pick up the fingerprinted icon/stylesheet URLs.
  def manifest
    render template: "pwa/manifest", formats: :json, layout: false,
           content_type: "application/manifest+json"
  end

  def service_worker
    # No-store: the browser re-fetches the worker on every update check, and a
    # cached worker is how a PWA gets stuck on stale code.
    response.headers["Cache-Control"] = "no-store"
    render template: "pwa/service_worker", formats: :js, layout: false,
           content_type: "text/javascript"
  end

  def offline
    render layout: false
  end
end
