// app/javascript/controllers/passkeys_controller.js
import { Controller } from "@hotwired/stimulus"
import { create } from '@github/webauthn-json'

export default class extends Controller {
  register() {
    fetch('/passkeys', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        phase: "initiation"
      })
    })
      .then(response => response.json())
      .then(options => {
        return create({ publicKey: options })
      })
      .then(credential => {
        fetch('/passkeys', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({ ...credential, phase: "verification" })
        })
        .then(response => {
          if (response.ok) {
            window.location.reload()
          } else {
            response.json().then(data => {
              console.error(data)
            })
            alert("Failed to register passkey")
          }
        })
      })
      .catch(error => {
        console.error(error)
        alert("Failed to register passkey")
      })
  }
}
