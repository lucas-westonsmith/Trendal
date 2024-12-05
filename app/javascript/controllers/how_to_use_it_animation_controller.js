import { Controller } from "@hotwired/stimulus"
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  static targets = ["animateElement"]; // Declare the target as an array

  connect() {
    console.log("How To Use It Animation Controller Connected");

    // Call the animation function when the controller connects
    this.addScrollTriggerAnimation();
  }

  addScrollTriggerAnimation() {
    // Loop through all the targets to apply animation to them
    this.animateElementTargets.forEach((element) => {
      gsap.from(element, {
        opacity: 0,
        y: 50, // Animation: Start from 50px below the original position
        duration: 1,
        ease: "power2.out",
        scrollTrigger: {
          trigger: element,
          start: "top 95%", // Trigger earlier: when the element reaches 90% of the viewport height
          end: "top 20%",
          toggleActions: "play none none reverse", // Play animation when entering, reverse when leaving
        },
      });
    });
  }
}
