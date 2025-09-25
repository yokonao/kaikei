import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async register() {
    try {
      const initiationResponse = await fetch("/passkeys", {
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
      const verificationResponse = await fetch("/passkeys", {
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
        alert("Failed to register passkey");
      }
    } catch (error) {
      console.error(error);
      alert("Failed to register passkey");
    }
  }
}
