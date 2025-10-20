/* global chrome */
document.addEventListener('DOMContentLoaded', async () => {
  const enabledToggle = document.getElementById('enabledToggle');
  const statusText = document.getElementById('statusText');
  const statusBadge = document.getElementById('statusBadge');
  const statToday = document.getElementById('statToday');
  const statTotal = document.getElementById('statTotal');
  const statLast = document.getElementById('statLast');
  const demoBtn = document.getElementById('demoBtn');
  const tryDemoBtn = document.getElementById('tryDemoBtn');
  const onboarding = document.getElementById('onboarding');
  const errorBanner = document.getElementById('errorBanner');

  function showError(msg) {
    if (!errorBanner) return;
    errorBanner.style.display = 'block';
    errorBanner.textContent = msg;
    errorBanner.setAttribute('role','alert');
  }

  function clearError() {
    if (!errorBanner) return;
    errorBanner.style.display = 'none';
    errorBanner.textContent = '';
  }

  function renderEnabled(enabled) {
    enabledToggle.checked = enabled;
    statusText.textContent = enabled ? 'Enabled' : 'Disabled';
    statusText.style.color = enabled ? 'var(--success)' : 'var(--fg-muted)';
    if (enabled) statusBadge.classList.add('active'); else statusBadge.classList.remove('active');
  }

  function renderStats(stats) {
    const last = stats.lastRedirectAt ? new Date(stats.lastRedirectAt).toLocaleString() : '—';
    statToday.textContent = `Today: ${stats.today || 0}`;
    statTotal.textContent = `Total: ${stats.total || 0}`;
    statLast.textContent = `Last: ${last}`;
  }

  async function loadState() {
    try {
      clearError();
      const res = await chrome.runtime.sendMessage({ type: 'getState' });
      if (!res?.ok) throw new Error(res?.error || 'Unknown error');
      renderEnabled(res.enabled);
      renderStats(res.stats);

      const { firstRun } = await chrome.storage.local.get('firstRun');
      if (firstRun) onboarding.style.display = 'block';
    } catch (e) {
      showError(`Unable to load state: ${e.message || e}`);
    }
  }

  enabledToggle.addEventListener('change', async (e) => {
    try {
      clearError();
      const res = await chrome.runtime.sendMessage({ type: 'setEnabled', enabled: e.target.checked });
      if (!res?.ok) throw new Error(res?.error || 'Toggle failed');
      renderEnabled(res.enabled);
      renderStats(res.stats);
    } catch (err) {
      showError(`Toggle failed: ${err.message || err}`);
      // revert UI
      enabledToggle.checked = !enabledToggle.checked;
    }
  });

  function runDemo() {
    // No special permissions required; let DNR perform the redirect
    window.open('https://www.youtube.com/watch?v=dQw4w9WgXcQ', '_blank', 'noopener');
  }

  demoBtn?.addEventListener('click', runDemo);
  tryDemoBtn?.addEventListener('click', async () => {
    runDemo();
    onboarding.style.display = 'none';
    await chrome.storage.local.set({ firstRun: false });
  });

  chrome.runtime.onMessage.addListener((msg) => {
    if (msg?.type === 'statsUpdated') loadState();
  });

  loadState();
});
