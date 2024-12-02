import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

// Register the ScrollTrigger plugin with GSAP
gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    console.log("ScrollVideoController connected"); // Log to confirm the controller is connected
    this.animateVideoOnScroll();
  }

  animateVideoOnScroll() {
    gsap.fromTo(
      ".large-video", // Target the video element
      { y: "100vh" }, // Start from below the viewport
      {
        y: "0", // Move to the top of the viewport
        scrollTrigger: {
          trigger: ".video-section", // Trigger the animation when the video section is in view
          start: "top bottom", // Start when the section is fully in view
          end: "top top", // End when the section reaches the top of the viewport
          scrub: true, // Smooth animation following the scroll position
          markers: false // Optional: Show start and end markers for debugging (set to true if you want them)
        }
      }
    );
  }
}
