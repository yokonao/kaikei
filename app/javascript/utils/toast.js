export function showErrorToast(message) {
  const template = document.querySelector('#error-toast-template');
  const id = `error-toast-${Date.now()}-${Math.random().toString(36).slice(-8)}`;
  const clone = template.content.cloneNode(true);

  clone.querySelector("[popover]").id = id;
  clone.querySelector("p").textContent = message;
  clone.querySelector("button").setAttribute("popovertarget", id);

  document.body.appendChild(clone);
  document.getElementById(id).showPopover();
}
