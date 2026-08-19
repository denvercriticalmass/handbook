import { Controller } from "@hotwired/stimulus"

// A details element opens on its own. This only adds what a menu needs and
// details doesn't: closing when you click away or press escape.
export default class extends Controller {
  connect() {
    this.listeners = new AbortController()

    document.addEventListener("click", this.#closeIfOutside, { signal: this.listeners.signal })
    document.addEventListener("keydown", this.#closeOnEscape, { signal: this.listeners.signal })
  }

  disconnect() {
    this.listeners.abort()
  }

  #closeIfOutside = (event) => {
    if (!this.element.contains(event.target)) this.element.open = false
  }

  #closeOnEscape = (event) => {
    if (event.key === "Escape") this.element.open = false
  }
}
