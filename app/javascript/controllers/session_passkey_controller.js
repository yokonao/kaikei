import { Controller } from "@hotwired/stimulus";
import { showErrorToast } from "utils/toast";

export default class extends Controller {
  async connect() {
    try {
      const initiationResponse = await fetch("/session", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({
          login_method: "passkey",
          phase: "initiation",
        }),
      });
      const initiationResponseJSON = await initiationResponse.json();
      const requestCredentialOptions =
        PublicKeyCredential.parseRequestOptionsFromJSON(initiationResponseJSON);
      const credential = await navigator.credentials.get({
        publicKey: requestCredentialOptions,
        mediation: "conditional",
      });
      const verificationResponse = await fetch("/session", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({
          ...credential.toJSON(),
          login_method: "passkey",
          phase: "verification",
        }),
      });
      if (verificationResponse.ok) {
        window.location.reload();
      } else {
        if (verificationResponse.status == 404) {
          if (PublicKeyCredential.signalUnknownCredential) {
            await PublicKeyCredential.signalUnknownCredential({
              rpId: window.location.hostname,
              credentialId: credential.id,
            });
            showErrorToast(
              "選択されたパスキーは既に登録解除されており、ご利用いただけません"
            );
          } else {
            showErrorToast(
              "選択されたパスキーは既に登録解除されており、ご利用いただけません。ご利用のデバイス等に保存されているパスキーを削除してください"
            );
          }

          return;
        }

        // verificationResponse.json().then((data) => {
        //   console.error(data);
        // });
        showErrorToast("パスキーの検証に失敗しました");
      }
    } catch (e) {
      if (e instanceof DOMException) {
        if (e.name === "NotAllowedError") {
          // ユーザーがパスキーの利用を許可しなかった、またはキャンセルしたことを示すため何もしない
          // https://www.w3.org/TR/webauthn-2/#sctn-privacy-considerations-client
          return;
        }
      }

      // console.error(e);
      showErrorToast("パスキーの検証に失敗しました");
    }
  }
}
