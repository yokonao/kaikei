import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "line", "debitContainer", "creditContainer", "debitTotal", "creditTotal", "difference"]

  connect() {
    this.updateTotals()
  }

  addDebitLine(event) {
    event.preventDefault()

    const template = this.createDebitLineTemplate()
    this.debitContainerTarget.insertAdjacentHTML('beforeend', template)
    this.updateTotals()
  }

  addCreditLine(event) {
    event.preventDefault()

    const template = this.createCreditLineTemplate()
    this.creditContainerTarget.insertAdjacentHTML('beforeend', template)
    this.updateTotals()
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

    // 差額がある場合は色を変更
    if (difference === 0) {
      this.differenceTarget.className = 'font-bold text-xl text-gray-600'
    } else {
      this.differenceTarget.className = 'font-bold text-xl text-black'
    }
  }

  getAccountOptions() {
    const existingSelect = this.element.querySelector('select[name*="[account_id]"]')
    if (existingSelect) {
      return Array.from(existingSelect.options)
        .slice(1) // Skip the first "prompt" option
        .map(option => `<option value="${option.value}">${option.text}</option>`)
        .join('')
    }
    return ''
  }

  createDebitLineTemplate() {
    const timestamp = new Date().getTime()
    const randomId = Math.random().toString(36).substr(2, 9)
    const fieldName = `journal_entry[journal_entry_lines_attributes][${timestamp}_${randomId}]`

    return `
      <div class="grid grid-cols-12 border-b hover:bg-gray-50" data-journal-entry-target="line">
        <input type="hidden" name="${fieldName}[side]" value="debit">

        <!-- 勘定科目 -->
        <div class="col-span-6 border-r p-0">
          <select name="${fieldName}[account_id]"
                  class="w-full h-full px-2 py-2 border-0 font-mono text-sm focus:outline-none focus:bg-yellow-100">
            <option value="">選択してください</option>
            ${this.getAccountOptions()}
          </select>
        </div>

        <!-- 金額 -->
        <div class="col-span-4 border-r p-0">
          <input type="number"
                 name="${fieldName}[amount]"
                 placeholder="0"
                 min="1"
                 max="999999999999"
                 class="w-full h-full px-2 py-2 border-0 font-mono text-sm text-right focus:outline-none focus:bg-yellow-100"
                 data-action="input->journal-entry#updateTotals">
        </div>

        <!-- 操作 -->
        <div class="col-span-2 border-r p-0 flex justify-center items-center">
          <button type="button"
                  class="w-full h-full font-mono text-xs cursor-pointer flex justify-center items-center"
                  data-action="click->journal-entry#removeLine"
                  aria-label="削除">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
      </div>
    `
  }

  createCreditLineTemplate() {
    const timestamp = new Date().getTime()
    const randomId = Math.random().toString(36).substr(2, 9)
    const fieldName = `journal_entry[journal_entry_lines_attributes][${timestamp}_${randomId}]`

    return `
      <div class="grid grid-cols-12 border-b hover:bg-gray-50" data-journal-entry-target="line">
        <input type="hidden" name="${fieldName}[side]" value="credit">

        <!-- 勘定科目 -->
        <div class="col-span-6 border-r p-0">
          <select name="${fieldName}[account_id]"
                  class="w-full h-full px-2 py-2 border-0 font-mono text-sm focus:outline-none focus:bg-yellow-100">
            <option value="">選択してください</option>
            ${this.getAccountOptions()}
          </select>
        </div>

        <!-- 金額 -->
        <div class="col-span-4 border-r p-0">
          <input type="number"
                 name="${fieldName}[amount]"
                 placeholder="0"
                 min="1"
                 max="999999999999"
                 class="w-full h-full px-2 py-2 border-0 font-mono text-sm text-right focus:outline-none focus:bg-yellow-100"
                 data-action="input->journal-entry#updateTotals">
        </div>

        <!-- 操作 -->
        <div class="col-span-2 p-0 flex justify-center items-center">
          <button type="button"
                  class="w-full h-full font-mono text-xs cursor-pointer flex justify-center items-center"
                  data-action="click->journal-entry#removeLine"
                  aria-label="削除">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
      </div>
    `
  }


  formatNumber(number) {
    return new Intl.NumberFormat('ja-JP').format(number)
  }
}
