/* global chrome */
document.addEventListener('DOMContentLoaded', async () => {
  const enabledToggle = document.getElementById('enabledToggle');
  const statusText = document.getElementById('statusText');
  const statusBadge = document.getElementById('statusBadge');
  const statToday = document.getElementById('statToday');
  const statTotal = document.getElementById('statTotal');
  const statActive = document.getElementById('statActive');
  const statLast = document.getElementById('statLast');
  const demoBtn = document.getElementById('demoBtn');
  const tryDemoBtn = document.getElementById('tryDemoBtn');
  const onboarding = document.getElementById('onboarding');
  const errorBanner = document.getElementById('errorBanner');

  // Add loading state
  function setLoading(isLoading) {
    if (isLoading) {
      document.body.classList.add('loading');
    } else {
      document.body.classList.remove('loading');
    }
  }

  function showError(msg) {
    if (!errorBanner) return;
    errorBanner.style.display = 'block';
    errorBanner.textContent = msg;
    errorBanner.setAttribute('role', 'alert');

    // Auto-hide after 5 seconds
    setTimeout(() => {
      clearError();
    }, 5000);
  }

  function clearError() {
    if (!errorBanner) return;
    errorBanner.style.display = 'none';
    errorBanner.textContent = '';
  }

  // Animate number changes
  function animateNumber(element, newValue) {
    const currentValue = parseInt(element.textContent) || 0;
    if (currentValue === newValue) return;

    const duration = 500;
    const steps = 20;
    const stepValue = (newValue - currentValue) / steps;
    let current = currentValue;
    let step = 0;

    const interval = setInterval(() => {
      step++;
      current += stepValue;

      if (step >= steps) {
        element.textContent = newValue;
        clearInterval(interval);
        // Add pulse animation
        element.style.animation = 'pulse 0.3s ease';
        setTimeout(() => {
          element.style.animation = '';
        }, 300);
      } else {
        element.textContent = Math.round(current);
      }
    }, duration / steps);
  }

  function renderEnabled(enabled) {
    enabledToggle.checked = enabled;
    statusText.textContent = enabled ? 'Enabled' : 'Disabled';
    statusText.style.color = enabled ? 'var(--success)' : 'var(--fg-tertiary)';
    statActive.textContent = enabled ? '✓' : '✗';
    statActive.style.color = enabled ? 'var(--success)' : 'var(--fg-tertiary)';

    if (enabled) {
      statusBadge.classList.add('active');
    } else {
      statusBadge.classList.remove('active');
    }
  }

  function renderStats(stats) {
    const today = stats.today || 0;
    const total = stats.total || 0;

    // Animate the numbers
    animateNumber(statToday, today);
    animateNumber(statTotal, total);

    // Format last redirect time
    if (stats.lastRedirectAt) {
      const lastDate = new Date(stats.lastRedirectAt);
      const now = new Date();
      const diffMs = now - lastDate;
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMs / 3600000);
      const diffDays = Math.floor(diffMs / 86400000);

      let timeStr;
      if (diffMins < 1) {
        timeStr = 'Just now';
      } else if (diffMins < 60) {
        timeStr = `${diffMins} min${diffMins > 1 ? 's' : ''} ago`;
      } else if (diffHours < 24) {
        timeStr = `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
      } else if (diffDays < 7) {
        timeStr = `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
      } else {
        timeStr = lastDate.toLocaleDateString();
      }

      statLast.innerHTML = `Last redirect: <strong>${timeStr}</strong>`;
    } else {
      statLast.innerHTML = 'Last redirect: <strong>—</strong>';
    }
  }

  async function loadState() {
    try {
      setLoading(true);
      clearError();

      const res = await chrome.runtime.sendMessage({ type: 'getState' });
      if (!res?.ok) throw new Error(res?.error || 'Unknown error');

      renderEnabled(res.enabled);
      renderStats(res.stats);

      // Check if first run
      const { firstRun } = await chrome.storage.local.get('firstRun');
      if (firstRun !== false) {
        onboarding.style.display = 'block';
      }
    } catch (e) {
      console.error('Failed to load state:', e);
      showError(`Unable to load state: ${e.message || e}`);
    } finally {
      setLoading(false);
    }
  }

  // Toggle handler with haptic feedback (scale animation)
  enabledToggle.addEventListener('change', async (e) => {
    try {
      setLoading(true);
      clearError();

      const res = await chrome.runtime.sendMessage({
        type: 'setEnabled',
        enabled: e.target.checked
      });

      if (!res?.ok) throw new Error(res?.error || 'Toggle failed');

      renderEnabled(res.enabled);
      renderStats(res.stats);

      // Visual feedback
      const statusSection = document.querySelector('.status');
      statusSection.style.transform = 'scale(1.02)';
      setTimeout(() => {
        statusSection.style.transform = '';
      }, 200);

    } catch (err) {
      console.error('Toggle error:', err);
      showError(`Toggle failed: ${err.message || err}`);
      // Revert UI
      enabledToggle.checked = !enabledToggle.checked;
    } finally {
      setLoading(false);
    }
  });

  function runDemo() {
    // Open a YouTube video to demonstrate redirect
    window.open('https://www.youtube.com/watch?v=dQw4w9WgXcQ', '_blank', 'noopener');

    // Visual feedback
    if (demoBtn) {
      demoBtn.style.transform = 'scale(0.95)';
      setTimeout(() => {
        demoBtn.style.transform = '';
      }, 150);
    }
  }

  // Demo button handlers
  demoBtn?.addEventListener('click', runDemo);

  tryDemoBtn?.addEventListener('click', async () => {
    runDemo();

    // Hide onboarding after first demo
    onboarding.style.animation = 'fadeOut 0.3s ease-out';
    setTimeout(() => {
      onboarding.style.display = 'none';
    }, 300);

    await chrome.storage.local.set({ firstRun: false });
  });

  // Listen for stats updates from background
  chrome.runtime.onMessage.addListener((msg) => {
    if (msg?.type === 'statsUpdated') {
      loadState();
    }
  });

  // Add keyboard shortcuts
  document.addEventListener('keydown', (e) => {
    // Space or Enter to toggle
    if (e.key === ' ' || e.key === 'Enter') {
      if (e.target === document.body) {
        e.preventDefault();
        enabledToggle.click();
      }
    }

    // 'T' for test
    if (e.key === 't' || e.key === 'T') {
      if (e.target === document.body) {
        e.preventDefault();
        runDemo();
      }
    }
  });

  // Add fadeOut animation to CSS dynamically
  if (!document.querySelector('style#dynamic-animations')) {
    const style = document.createElement('style');
    style.id = 'dynamic-animations';
    style.textContent = `
      @keyframes fadeOut {
        from {
          opacity: 1;
          transform: translateY(0);
        }
        to {
          opacity: 0;
          transform: translateY(-10px);
        }
      }
    `;
    document.head.appendChild(style);
  }

  // Initial load
  loadState();
});
