import { Controller } from "@hotwired/stimulus"

// Riders open the list before they lose the network, not each sheet in turn.
export default class extends Controller {
  connect() {
    navigator.serviceWorker?.controller?.postMessage({ prefetch: this.paths })
  }

  get paths() {
    return [ ...this.element.querySelectorAll("a[href]") ].map((link) => link.pathname)
  }
}
