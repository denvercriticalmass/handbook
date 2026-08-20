import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import removeButton from "tom-select/plugins/remove_button"

TomSelect.define("remove_button", removeButton)

export default class extends Controller {
  static values = { options: Array }

  connect() {
    this.select = new TomSelect(this.element, {
      delimiter: ",",
      persist: false,
      create: true,
      createOnBlur: true,
      clearAfterSelect: true,
      selectOnTab: true,
      plugins: ["remove_button"],
      options: this.optionsValue.map((tag) => ({ value: tag, text: tag })),
      onFocus: () => this.element.setAttribute("aria-expanded", "true"),
      onBlur: () => this.element.setAttribute("aria-expanded", "false")
    })
  }

  disconnect() {
    this.select.destroy()
  }
}
