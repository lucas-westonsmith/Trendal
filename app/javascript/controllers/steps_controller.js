import { Controller } from "@hotwired/stimulus"
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    const steps = document.querySelectorAll(".steps-child-container");

    gsap.fromTo(
      steps,
      {
        x: "30%",  // Start from a smaller distance for a smoother entry
        opacity: 0  // Fully transparent
      },
      {
        x: "0%",  // End at the original position
        opacity: 1,  // Fully visible
        duration: 1.8,  // Slightly longer duration for smoother transition
        ease: "power2.out",  // Smooth easing effect for slower deceleration
        stagger: 0.4,  // Delay each animation by 0.4 seconds
        scrollTrigger: {
          trigger: steps[0],  // Use the first step to trigger the scroll animation
          start: "top 90%",  // Start when the element is near the bottom of the viewport
          end: "top 60%",  // End when the element is near the top of the viewport
          scrub: 0.5,  // Smoother scroll interaction with a slower pace
          markers: false  // Optional: Enable this for debugging
        }
      }
    );
  }
}
