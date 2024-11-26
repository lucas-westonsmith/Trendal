import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["row"];

  connect() {
    this.rowTargets.forEach((row) => {
      row.addEventListener("click", this.navigate.bind(this));
    });
  }

  navigate(event) {
    const href = event.currentTarget.dataset.href;
    if (href) {
      window.location.href = href;
    }
  }
}

