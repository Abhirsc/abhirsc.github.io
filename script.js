document.addEventListener('DOMContentLoaded', () => {
  const items = document.querySelectorAll('.timeline-item');

  const observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if(entry.isIntersecting) {
        entry.target.classList.add('show');
        observer.unobserve(entry.target); // Optional: stop observing once shown
      }
    });
  }, { threshold: 0.2 });

  items.forEach(item => {
    observer.observe(item);
  });
});
