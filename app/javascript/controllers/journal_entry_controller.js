import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  updateAccountId(event) {
    const accountNameInput = event.target
    const line = accountNameInput.closest('[data-journal-entry-target="line"]')
    const accountIdInput = line.querySelector('input[name*="[account_id]"]')
    const datalist = document.getElementById(accountNameInput.getAttribute('list'))

    if (datalist) {
      const options = datalist.querySelectorAll('option')
      const matchingOption = Array.from(options).find(option =>
        option.value === accountNameInput.value
      )

      if (matchingOption) {
        accountIdInput.value = matchingOption.getAttribute('data-account-id')
      } else {
        accountIdInput.value = ''
      }
    }
  }
}
