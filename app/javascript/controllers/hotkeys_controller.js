import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["journalEditorDialog"];

  initialize() {
    this.boundHotkeysHandler = this.hotkeysHandler.bind(this);
  }

  connect() {
    document.addEventListener("keydown", this.boundHotkeysHandler);
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHotkeysHandler);
  }

  hotkeysHandler(event) {
    const isModifierKeyPressed = event.metaKey || event.ctrlKey;
    const dotKey = event.key === ".";

    if (isModifierKeyPressed && dotKey) {
      this.journalEditorDialogTarget.showModal();
    }
  }
}
