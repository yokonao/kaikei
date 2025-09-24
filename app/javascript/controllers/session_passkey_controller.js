import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async authenticate() {
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
        PublicKeyCredential.parseRequestOptionsFromJSON(
          initiationResponseJSON
        );
      const credential = await navigator.credentials.get({
        publicKey: requestCredentialOptions,
      });
      const verificationResponse = await fetch("/session", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({ ...credential.toJSON(), login_method: "passkey", phase: "verification" }),
      });
      if (verificationResponse.ok) {
        window.location.reload();
      } else {
        // verificationResponse.json().then((data) => {
        //   console.error(data);
        // });
        alert("Failed to authenticate passkey");
      }
    } catch (error) {
      // console.error(error);
      alert("Failed to authenticate passkey");
    }
  }
}
