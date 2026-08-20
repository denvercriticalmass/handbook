import { Controller } from "@hotwired/stimulus"
import { create, supported } from "@github/webauthn-json"

export default class extends Controller {
  static targets = ["credential"]

  connect() {
    if (!supported()) this.element.hidden = true
  }

  async enroll(event) {
    event.preventDefault()

    try {
      const options = await this.#challenge()
      this.credentialTarget.value = JSON.stringify(await create({ publicKey: options }))
    } catch {
      // A cancelled prompt or an authenticator that declines is not an error worth showing.
      return
    }

    // submit() rather than requestSubmit() so this handler does not see it again.
    this.element.submit()
  }

  async #challenge() {
    const response = await fetch("/admin/passkey_challenge", {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      }
    })

    return await response.json()
  }
}
