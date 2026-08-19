import { Controller } from "@hotwired/stimulus"

// The pages cached during a session can carry that admin's nav.
export default class extends Controller {
  connect() {
    navigator.serviceWorker?.controller?.postMessage({ forget: "pages" })
  }
}
