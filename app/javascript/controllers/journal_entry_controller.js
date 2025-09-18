import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "line", "debitContainer", "creditContainer", "debitTotal", "creditTotal", "difference"]

  connect() {
    this.updateTotals()
  }

  addDebitLine(event) {
    event.preventDefault()
    const template = this.getLineTemplate('debit')
    this.debitContainerTarget.insertAdjacentHTML('beforeend', template)
    this.updateTotals()
  }

  addCreditLine(event) {
    event.preventDefault()
    const template = this.getLineTemplate('credit')
    this.creditContainerTarget.insertAdjacentHTML('beforeend', template)
    this.updateTotals()
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
      this.updateTotals()
    }
  }

  markForDestroy(event) {
    const line = event.target.closest('[data-journal-entry-target="line"]')
    if (event.target.checked) {
      line.style.opacity = '0.5'
    } else {
      line.style.opacity = '1'
    }
    this.updateTotals()
  }

  updateTotals() {
    let debitTotal = 0
    let creditTotal = 0

    this.lineTargets.forEach(line => {
      const destroyCheckbox = line.querySelector('input[name*="_destroy"]')
      if (destroyCheckbox && destroyCheckbox.checked) {
        return
      }

      const sideInput = line.querySelector('input[name*="[side]"]')
      const amountInput = line.querySelector('input[name*="[amount]"]')

      if (sideInput && amountInput && amountInput.value) {
        const amount = parseFloat(amountInput.value) || 0

        if (sideInput.value === 'debit') {
          debitTotal += amount
        } else if (sideInput.value === 'credit') {
          creditTotal += amount
        }
      }
    })

    const difference = debitTotal - creditTotal

    this.debitTotalTarget.textContent = this.formatNumber(debitTotal)
    this.creditTotalTarget.textContent = this.formatNumber(creditTotal)
    this.differenceTarget.textContent = this.formatNumber(difference)
  }

  formatNumber(number) {
    return new Intl.NumberFormat('ja-JP').format(number)
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
