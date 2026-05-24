/* ============================================================
   LelangKu Admin Panel — Client-side JavaScript
   Handles: Lucide icons, sidebar toggle, charts, countdowns,
   animated counters, live clock, password toggle
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {
  // Initialize Lucide icons
  if (typeof lucide !== 'undefined') {
    lucide.createIcons();
  }

  initSidebar();
  initClock();
  initPasswordToggle();
  initAnimatedCounters();
  initCharts();
  initCountdowns();
});

/* ── Sidebar Toggle (Mobile) ── */
function initSidebar() {
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('sidebarOverlay');
  const openBtn = document.getElementById('sidebarOpen');
  const closeBtn = document.getElementById('sidebarClose');

  if (!sidebar) return;

  function openSidebar() {
    sidebar.classList.add('open');
    if (overlay) overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeSidebar() {
    sidebar.classList.remove('open');
    if (overlay) overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  if (openBtn) openBtn.addEventListener('click', openSidebar);
  if (closeBtn) closeBtn.addEventListener('click', closeSidebar);
  if (overlay) overlay.addEventListener('click', closeSidebar);
}

/* ── Live Clock ── */
function initClock() {
  const clockEl = document.getElementById('topbar-clock');
  if (!clockEl) return;

  function update() {
    const now = new Date();
    clockEl.textContent = now.toLocaleTimeString('id-ID', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
  }

  update();
  setInterval(update, 1000);
}

/* ── Password Toggle ── */
function initPasswordToggle() {
  const toggleBtn = document.getElementById('passwordToggle');
  const passwordInput = document.getElementById('password');

  if (!toggleBtn || !passwordInput) return;

  toggleBtn.addEventListener('click', () => {
    const isPassword = passwordInput.type === 'password';
    passwordInput.type = isPassword ? 'text' : 'password';

    // Update icon
    const icon = toggleBtn.querySelector('svg, i');
    if (icon) {
      icon.setAttribute('data-lucide', isPassword ? 'eye-off' : 'eye');
      if (typeof lucide !== 'undefined') lucide.createIcons();
    }
  });
}

/* ── Animated Counters ── */
function initAnimatedCounters() {
  const counters = document.querySelectorAll('[data-count]');

  counters.forEach((el) => {
    const target = parseFloat(el.dataset.count) || 0;
    const isCurrency = el.classList.contains('stat-currency');
    const duration = 1500;
    const startTime = performance.now();

    function animate(currentTime) {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);

      // Ease out cubic
      const eased = 1 - Math.pow(1 - progress, 3);
      const current = target * eased;

      if (isCurrency) {
        el.textContent = 'Rp ' + Math.round(current).toLocaleString('id-ID');
      } else {
        el.textContent = Math.round(current).toLocaleString('id-ID');
      }

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    }

    requestAnimationFrame(animate);
  });
}

/* ── Chart.js Charts ── */
function initCharts() {
  const chartData = window.__chartData;
  if (!chartData) return;

  // Common chart options
  const darkTheme = {
    color: '#8888a0',
    borderColor: 'rgba(255,255,255,0.06)',
  };

  Chart.defaults.color = darkTheme.color;
  Chart.defaults.borderColor = darkTheme.borderColor;
  Chart.defaults.font.family = "'Inter', sans-serif";

  // Payment Status — Doughnut
  const paymentCtx = document.getElementById('paymentChart');
  if (paymentCtx && chartData.paymentStatus) {
    new Chart(paymentCtx, {
      type: 'doughnut',
      data: {
        labels: Object.keys(chartData.paymentStatus).map(capitalize),
        datasets: [
          {
            data: Object.values(chartData.paymentStatus),
            backgroundColor: ['#ffc93c', '#00c9a7', '#ff6b6b'],
            borderWidth: 0,
            hoverOffset: 8,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '65%',
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 16,
              usePointStyle: true,
              pointStyleWidth: 8,
              font: { size: 11 },
            },
          },
        },
      },
    });
  }

  // Categories — Bar
  const categoryCtx = document.getElementById('categoryChart');
  if (categoryCtx && chartData.categories) {
    const cats = Object.keys(chartData.categories);
    const vals = Object.values(chartData.categories);

    new Chart(categoryCtx, {
      type: 'bar',
      data: {
        labels: cats.map(capitalize),
        datasets: [
          {
            label: 'Auctions',
            data: vals,
            backgroundColor: createGradientColors(cats.length),
            borderRadius: 6,
            borderSkipped: false,
            barThickness: 28,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1, font: { size: 10 } },
            grid: { color: 'rgba(255,255,255,0.04)' },
          },
          x: {
            ticks: { font: { size: 10 } },
            grid: { display: false },
          },
        },
      },
    });
  }

  // Roles — Doughnut
  const roleCtx = document.getElementById('roleChart');
  if (roleCtx && chartData.roles) {
    new Chart(roleCtx, {
      type: 'doughnut',
      data: {
        labels: Object.keys(chartData.roles).map(capitalize),
        datasets: [
          {
            data: Object.values(chartData.roles),
            backgroundColor: ['#e94560', '#4ecdc4', '#6c5ce7'],
            borderWidth: 0,
            hoverOffset: 8,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '65%',
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 16,
              usePointStyle: true,
              pointStyleWidth: 8,
              font: { size: 11 },
            },
          },
        },
      },
    });
  }
}

/* ── Countdown Timers ── */
function initCountdowns() {
  const countdowns = document.querySelectorAll('.countdown[data-end]');

  countdowns.forEach((el) => {
    const endTime = new Date(el.dataset.end).getTime();

    function update() {
      const now = Date.now();
      const diff = endTime - now;

      if (diff <= 0) {
        el.textContent = 'Ended';
        el.style.color = '#ff6b6b';
        return;
      }

      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((diff % (1000 * 60)) / 1000);

      const parts = [];
      if (days > 0) parts.push(`${days}d`);
      parts.push(`${String(hours).padStart(2, '0')}h`);
      parts.push(`${String(minutes).padStart(2, '0')}m`);
      parts.push(`${String(seconds).padStart(2, '0')}s`);

      el.textContent = parts.join(' ');
    }

    update();
    setInterval(update, 1000);
  });
}

/* ── Utility Functions ── */
function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function createGradientColors(count) {
  const palette = [
    '#e94560',
    '#6c5ce7',
    '#00c9a7',
    '#ffc93c',
    '#4ecdc4',
    '#a29bfe',
    '#ff6b6b',
    '#55efc4',
    '#fd79a8',
    '#74b9ff',
  ];
  return Array.from({ length: count }, (_, i) => palette[i % palette.length]);
}
