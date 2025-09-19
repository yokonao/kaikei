import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "line", "debitContainer", "creditContainer", "debitTotal", "creditTotal", "difference"]

  addDebitLine(event) {
    event.preventDefault()
    const template = this.getLineTemplate('debit')
    this.debitContainerTarget.insertAdjacentHTML('beforeend', template)
  }

  addCreditLine(event) {
    event.preventDefault()
    const template = this.getLineTemplate('credit')
    this.creditContainerTarget.insertAdjacentHTML('beforeend', template)
  }

  getLineTemplate(side) {
    const timestamp = new Date().getTime()
    const randomId = Math.random().toString(36).substring(2)
    const fieldName = `journal_entry[journal_entry_lines_attributes][${timestamp}_${randomId}]`

    // ERB側で事前生成されたテンプレートを使用
    const templateElement = document.getElementById(`journal-entry-line-template`)
    if (templateElement) {
      return templateElement.innerHTML
        .replace(/__FIELD_NAME_PLACEHOLDER__/g, fieldName)
        .replace(/__SIDE_PLACEHOLDER__/g, side)
    }

    return ''
  }

  removeLine(event) {
    event.preventDefault()

    const line = event.target.closest('[data-journal-entry-target="line"]')
    if (line) {
      line.remove()
    }
  }

  markForDestroy(event) {
    const line = event.target.closest('[data-journal-entry-target="line"]')
    if (event.target.checked) {
      line.style.opacity = '0.5'
    } else {
      line.style.opacity = '1'
    }
  }

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
