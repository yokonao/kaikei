import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const inputElements = this.element.querySelectorAll(
      "input:not([type='submit'])"
    );
    inputElements.forEach((inputElement) => {
      inputElement.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
          event.preventDefault();

          const isModifierKeyPressed = event.metaKey || event.ctrlKey;
          if (isModifierKeyPressed) {
            inputElement.form.submit();
          }
        }
      });
    });
  }
}
