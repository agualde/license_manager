import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productCheckbox", "userCheckbox", "button"]

  connect() {
    this.validate()
  }

  validate() {
    const hasProductSelected = this.productCheckboxTargets.some(cb => cb.checked)
    const hasUserSelected = this.userCheckboxTargets.some(cb => cb.checked)
    const shouldEnable = hasProductSelected && hasUserSelected

    this.buttonTargets.forEach(button => {
      button.disabled = !shouldEnable
    })
  }
}