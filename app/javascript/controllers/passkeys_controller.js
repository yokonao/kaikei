import { Controller } from "@hotwired/stimulus";
import { showErrorToast } from "utils/toast";

export default class extends Controller {
  static values = {
    userId: Number,
  };

  async register() {
    try {
      const initiationResponse = await fetch(
        `/users/${this.userIdValue}/public_key_credential_creation_options`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
      const initiationResponseJSON = await initiationResponse.json();
      const createCredentialOptions =
        PublicKeyCredential.parseCreationOptionsFromJSON(
          initiationResponseJSON
        );
      const credential = await navigator.credentials.create({
        publicKey: createCredentialOptions,
      });
      const verificationResponse = await fetch(
        `/users/${this.userIdValue}/passkeys`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
              .content,
          },
          body: JSON.stringify(credential.toJSON()),
        }
      );
      if (verificationResponse.ok) {
        window.location.reload();
      } else {
        // verificationResponse.json().then((data) => {
        //   console.error(data);
        // });
        showErrorToast("パスキーの登録に失敗しました。");
      }
    } catch (e) {
      if (e instanceof DOMException) {
        if (e.name === "NotAllowedError") {
          // ユーザーがパスキーの登録を許可しなかった、またはキャンセルしたことを示すため何もしない
          // https://www.w3.org/TR/webauthn-2/#sctn-privacy-considerations-client
          return;
        }

        if (
          e.name === "InvalidStateError" &&
          e.message.includes("already registered")
        ) {
          showErrorToast(
            "指定された認証器は既に登録されています。他の認証器を選択してください。"
          );
          return;
        }
      }

      // console.error(e);
      showErrorToast("パスキーの登録に失敗しました。");
    }
  }
}
