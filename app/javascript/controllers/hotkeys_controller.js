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
      // モーダルが重複しないように制御している
      // TODO: もしかしたら同じ <dialog> でも showModal() で開いたか、show() で開いたかで処理を分けたほうがいいかもしれない？
      if (!document.querySelector('dialog[open]')) {
        this.journalEditorDialogTarget.showModal();
      }
    }
  }
}
