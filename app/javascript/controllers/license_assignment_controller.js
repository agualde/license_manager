// controllers/license_assignment_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productCheckbox", "userCheckbox", "unassignForm"]

  unassign(event) {
    event.preventDefault()

    const checkedProducts = this.productCheckboxTargets.filter(cb => cb.checked)
    const checkedUsers = this.userCheckboxTargets.filter(cb => cb.checked)

    if (checkedProducts.length === 0 || checkedUsers.length === 0) {
      alert("Please select both users and products to unassign.")
      return
    }

    // ❌ was: remove all hidden inputs (kills _method & CSRF)
    // ✅ only remove previously-added dynamic params
    this.unassignFormTarget
      .querySelectorAll('input[name="product_ids[]"], input[name="user_ids[]"]')
      .forEach(input => input.remove())

    checkedProducts.forEach(cb => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'product_ids[]'
      input.value = cb.value
      this.unassignFormTarget.appendChild(input)
    })

    checkedUsers.forEach(cb => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'user_ids[]'
      input.value = cb.value
      this.unassignFormTarget.appendChild(input)
    })

    this.unassignFormTarget.submit() // now keeps _method=delete + CSRF
  }
}
