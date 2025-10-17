import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    allAcceptedCredentialIds: Array,
    emailAddress: String,
    webauthnUserHandle: String,
  };

  async connect() {
    if (PublicKeyCredential.signalCurrentUserDetails) {
      await PublicKeyCredential.signalCurrentUserDetails({
        rpId: window.location.hostname,
        userId: this.webauthnUserHandleValue,
        name: this.emailAddressValue,
        displayName: this.emailAddressValue,
      });
    }

    if (PublicKeyCredential.signalAllAcceptedCredentials) {
      await PublicKeyCredential.signalAllAcceptedCredentials({
        rpId: window.location.hostname,
        userId: this.webauthnUserHandleValue,
        allAcceptedCredentialIds: this.allAcceptedCredentialIdsValue,
      });
    }
  }
}
