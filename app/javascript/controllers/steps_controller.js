import { Controller } from "@hotwired/stimulus"
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    const steps = document.querySelectorAll(".steps-child-container");

    steps.forEach((step, index) => {
      gsap.from(step, {
        x: "100%",  // Animate from the right
        opacity: 0,
        duration: 1.5,  // Increased duration for smoother animation
        ease: "power3.out",  // Smooth easing effect
        scrollTrigger: {
          trigger: step,
          start: "top 80%",
          end: "top 60%",
          scrub: 0.5,  // Smoother scroll interaction
        },
      });
    });
  }
}
