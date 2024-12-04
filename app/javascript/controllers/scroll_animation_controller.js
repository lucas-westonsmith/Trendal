import { Controller } from "@hotwired/stimulus"
import gsap from "gsap";

export default class extends Controller {
  static targets = ["section"];

  connect() {
    this.animateOnScroll();
  }

  animateOnScroll() {
    window.addEventListener("scroll", () => {
      const section = this.sectionTarget;
      const sectionTop = section.getBoundingClientRect().top;
      const windowHeight = window.innerHeight;

      // This checks how far the section is from the top of the window as the user scrolls
      const scrollPercentage = (windowHeight - sectionTop) / windowHeight;

      // When the section comes into view (scrollPercentage between 0 and 1), apply the animation
      if (scrollPercentage > 0 && scrollPercentage < 1) {
        this.animateText(scrollPercentage);
      }
    });
  }

  animateText(scrollPercentage) {
    // Control opacity and vertical movement based on the scrollPercentage
    gsap.to(this.sectionTarget.querySelector('.text'), {
      opacity: scrollPercentage,
      y: 50 * (1 - scrollPercentage), // Text will move upwards as it appears
      duration: 0.3,
      ease: "power2.out",
    });
  }
}
