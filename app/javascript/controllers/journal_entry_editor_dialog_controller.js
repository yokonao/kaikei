import { Controller } from "@hotwired/stimulus";
import { showErrorToast } from "utils/toast";

export default class extends Controller {
  static targets = ["form"];

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
            inputElement.form.dispatchEvent(
              new Event("submit", {
                bubbles: true,
                cancelable: true,
              })
            );
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
    try {
      // フォームデータを手動で JSON オブジェクトに変換している
      // この実装はオブジェクト構造の変化に弱い点に注意
      // TODO: ライブラリを導入するなどして、オブジェクト変換のロジックを汎用的にして構造の変化に耐性を持たせる
      const data = new FormData(form);
      const json = { journal_entry: { journal_entry_lines_attributes: {} } };
      for (const [key, value] of data.entries()) {
        if (key === "journal_entry[entry_date]") {
          json.journal_entry.entry_date = value;
          continue;
        } else if (key === "journal_entry[summary]") {
          json.journal_entry.summary = value;
          continue;
        }
        const regex =
          /journal_entry\[journal_entry_lines_attributes\]\[(?<index>\d+)\]\[(?<attributeKey>[a-zA-Z_]+)\]/;
        for (const [key, value] of data.entries()) {
          const match = regex.exec(key);
          if (match) {
            const { index, attributeKey } = match.groups;
            if (!json.journal_entry.journal_entry_lines_attributes[index]) {
              json.journal_entry.journal_entry_lines_attributes[index] = {};
            }
            if (
              !json.journal_entry.journal_entry_lines_attributes[index][
                attributeKey
              ]
            ) {
              json.journal_entry.journal_entry_lines_attributes[index][
                attributeKey
              ] = value;
            }
          }
        }
      }

      const body = JSON.stringify(json);

      const response = await fetch("/companies/1/journal_entries", {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: body,
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
    }
  }
}
