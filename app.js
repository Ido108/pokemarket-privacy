// Minimal interactivity — scroll-in, tooltip toggle on hero tile tap
document.addEventListener('DOMContentLoaded', () => {
  // Fade-in on scroll
  const io = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (e.isIntersecting) {
        e.target.classList.add('in');
        io.unobserve(e.target);
      }
    }
  }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });

  document.querySelectorAll('.how__step, .feat, .site-card, .privacy__card, .stats__item, .cta__inner')
    .forEach(el => { el.classList.add('will-in'); io.observe(el); });

  // Hero tooltip — gentle idle float
  const tooltip = document.getElementById('heroTooltip');
  if (tooltip) {
    let t = 0;
    const loop = () => {
      t += 0.01;
      tooltip.style.setProperty('--ty', `${Math.sin(t) * 4}px`);
      requestAnimationFrame(loop);
    };
    loop();
  }

  // Ungraded / PSA 10 toggle (demo only)
  document.querySelectorAll('.tooltip__toggle').forEach(group => {
    group.querySelectorAll('button').forEach(btn => {
      btn.addEventListener('click', () => {
        group.querySelectorAll('button').forEach(b => b.classList.remove('is-active'));
        btn.classList.add('is-active');
      });
    });
  });

  // Main / Full Set / Edit Match tabs
  document.querySelectorAll('.tooltip__tabs').forEach(group => {
    group.querySelectorAll('button').forEach(btn => {
      btn.addEventListener('click', () => {
        group.querySelectorAll('button').forEach(b => b.classList.remove('is-active'));
        btn.classList.add('is-active');
      });
    });
  });

  // Popup sort pills demo
  document.querySelectorAll('.popup-mock__sort').forEach(group => {
    group.querySelectorAll('button:not(.popup-mock__reset)').forEach(btn => {
      btn.addEventListener('click', () => {
        group.querySelectorAll('button').forEach(b => b.classList.remove('is-active'));
        btn.classList.add('is-active');
      });
    });
  });
});
