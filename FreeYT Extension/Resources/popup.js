(function(){
  'use strict';

  const enabledToggle = document.getElementById('enabledToggle');
  const statusText = document.getElementById('statusText');

  const STORAGE_KEY = 'enabled';

  // Update UI based on enabled state
  function setStatusUI(enabled) {
    enabledToggle.checked = enabled;
    statusText.textContent = enabled ? 'Enabled' : 'Disabled';
    statusText.style.color = enabled ? 'var(--success)' : 'var(--fg-muted)';
  }

  // Initialize popup
  async function init() {
    try {
      // Get current state from storage
      const result = await chrome.storage.local.get(STORAGE_KEY);
      const enabled = result[STORAGE_KEY] ?? true;
      setStatusUI(enabled);

      // Listen for toggle changes
      enabledToggle.addEventListener('change', async () => {
        const newState = enabledToggle.checked;
        await chrome.storage.local.set({ [STORAGE_KEY]: newState });
        setStatusUI(newState);
        console.log('[FreeYT Popup] State changed to:', newState);
      });

      console.log('[FreeYT Popup] Initialized, current state:', enabled);
    } catch (error) {
      console.error('[FreeYT Popup] Initialization error:', error);
    }
  }

  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
