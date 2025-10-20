import { Controller } from "@hotwired/stimulus";
import { showErrorToast } from "utils/toast";

export default class extends Controller {
  static targets = ["form", "submit"];

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
            this.submitTarget.click();
          }
        }
      });
    });

    this.formTarget.addEventListener("submit", async (event) => {
      event.preventDefault();
      await this.sendJSON(event.target);
    });
  }

  async sendJSON(form) {
    this.submitTarget.disabled = true;

    try {
      const formData = new FormData(form);
      const encodedData = new URLSearchParams(formData).toString();

      const response = await fetch("/companies/1/journal_entries", {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: encodedData,
      });

      const responseJSON = await response.json();

      if (response.ok) {
        // TODO: Toast UI を出す
        console.log("仕訳を正常に作成しました");
      } else {
        const message = responseJSON.errors
          ? responseJSON.errors.join("\n")
          : "仕訳の作成に失敗しました";
        showErrorToast(message);
      }
    } catch {
      showErrorToast("仕訳の保存に失敗しました");
    } finally {
      this.submitTarget.disabled = false;
    }
  }
}
