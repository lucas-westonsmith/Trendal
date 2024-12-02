import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";

export default class extends Controller {
  connect() {
    // Apply animation to elements within the .gradient section
    gsap.from(".animate-text", {
      opacity: 0,
      y: 20,
      duration: 1,
      stagger: 0.3
    });

    gsap.from(".animate-button", {
      opacity: 0,
      y: 30,
      duration: 1,
      delay: 1,
    });
  }
}
