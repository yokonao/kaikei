import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["companyDstructionDialog"]

  confirmCompanyDestruction() {
    this.companyDstructionDialogTarget.showModal()
  }

  closeCompanyDestructionDialog() {
    this.companyDstructionDialogTarget.close()
  }

  onCompanyDestructionConfirmationTextChange(event) {
    const current = event.target.value
    const correct = event.target.dataset.correctConfirmationText
    if (current === correct) {
      event.target.setCustomValidity("")
    } else {
      event.target.setCustomValidity(`「${correct}」と入力してください`)
    }
  }
}
