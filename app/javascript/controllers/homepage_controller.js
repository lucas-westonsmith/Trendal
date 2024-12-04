import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";

export default class extends Controller {
  connect() {
    // Apply animation to text elements with .animate-text class
    gsap.from(".animate-text", {
      opacity: 0,
      y: 20,
      duration: 1,
      stagger: 0.3 // Stagger the animation of multiple elements
    });

    // Apply animation to buttons with .animate-button class
    gsap.from(".animate-button", {
      opacity: 0,
      y: 30,
      duration: 1,
      delay: 1, // Delay the button animation to start after text
    });
  }
}
