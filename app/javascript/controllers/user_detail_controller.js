import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["userDstructionDialog"]

  confirmUserDestruction() {
    this.userDstructionDialogTarget.showModal()
  }

  closeUserDestructionDialog() {
    this.userDstructionDialogTarget.close()
  }

  onUserDestructionConfirmationTextChange(event) {
    const current = event.target.value
    const correct = event.target.dataset.correctConfirmationText
    if (current === correct) {
      event.target.setCustomValidity("")
    } else {
      event.target.setCustomValidity(`「${correct}」と入力してください`)
    }
  }
}
