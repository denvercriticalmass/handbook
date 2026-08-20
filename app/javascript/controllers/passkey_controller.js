import { create, get, supported } from "@github/webauthn-json"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["credential"]
  static values = { challengeUrl: String }

  connect() {
    if (!supported()) this.element.hidden = true
  }

  enroll(event) {
    this.#ceremony(event, create)
  }

  signin(event) {
    this.#ceremony(event, get)
  }

  async #ceremony(event, ask) {
    event.preventDefault()

    try {
      const publicKey = await this.#challenge()
      this.credentialTarget.value = JSON.stringify(await ask({ publicKey }))
    } catch {
      // A cancelled prompt or an authenticator that declines is not an error worth showing.
      return
    }

    // submit() rather than requestSubmit() so this handler does not see it again.
    this.element.submit()
  }

  async #challenge() {
    const response = await fetch(this.challengeUrlValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      }
    })

    return await response.json()
  }
}
