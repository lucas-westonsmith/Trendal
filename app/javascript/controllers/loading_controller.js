import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading"];

  connect() {
    console.log("hello")
    this.loadingTarget.style.display = "none"; // Hide loading by default
  }

  submit() {
    this.loadingTarget.style.display = "flex"; // Show loading when form is submitted
  }
}
