// Simple fade-in effect when timeline items scroll into view
const items = document.querySelectorAll('.timeline-item');

const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('show');
    }
  });
}, { threshold: 0.1 });

items.forEach(item => {
  observer.observe(item);
});
