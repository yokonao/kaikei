import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["memberAdditionDialog"]

  openMemberAdditionDialog() {
    this.memberAdditionDialogTarget.showModal()
  }

  closeMemberAdditionDialog() {
    this.memberAdditionDialogTarget.close()
  }
}
