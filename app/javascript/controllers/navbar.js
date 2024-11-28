document.addEventListener('DOMContentLoaded', () => {
  const navLinks = document.querySelectorAll('.nav-link');

  // Function to set the active class based on the current URL
  const setActiveLink = () => {
    const currentPath = window.location.pathname; // Get the current path

    navLinks.forEach(link => {
      // Remove active class from all links
      link.classList.remove('active');

      // Compare link's href with current path to set active class
      if (link.getAttribute('href') === currentPath) {
        link.classList.add('active');
      }
    });
  };

  // Run on page load to set the active link
  setActiveLink();

  // Optional: Re-add active class on click (if using Turbo or dynamic content)
  navLinks.forEach(link => {
    link.addEventListener('click', () => {
      navLinks.forEach(nav => nav.classList.remove('active'));
      link.classList.add('active');
    });
  });
});
