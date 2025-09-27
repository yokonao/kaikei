import { Controller } from "@hotwired/stimulus";
import { showErrorToast } from "utils/toast";

export default class extends Controller {
  async register() {
    try {
      const initiationResponse = await fetch("/users/passkeys", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({
          phase: "initiation",
        }),
      });
      const initiationResponseJSON = await initiationResponse.json();
      const createCredentialOptions =
        PublicKeyCredential.parseCreationOptionsFromJSON(
          initiationResponseJSON
        );
      const credential = await navigator.credentials.create({
        publicKey: createCredentialOptions,
      });
      const verificationResponse = await fetch("/users/passkeys", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({ ...credential.toJSON(), phase: "verification" }),
      });
      if (verificationResponse.ok) {
        window.location.reload();
      } else {
        // verificationResponse.json().then((data) => {
        //   console.error(data);
        // });
        showErrorToast("Failed to register passkey");
      }
    } catch (e) {
      if (
        e.name === "InvalidStateError" &&
        e.message.includes("already registered")
      ) {
        showErrorToast(
          "指定された認証器は既に登録されています。他の認証器を選択してください。"
        );
        return;
      }
      // console.error(e);
      showErrorToast("Failed to register passkey");
    }
  }
}
