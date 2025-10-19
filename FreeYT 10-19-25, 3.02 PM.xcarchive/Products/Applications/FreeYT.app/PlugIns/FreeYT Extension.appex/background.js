// FreeYT Background Service Worker
// Intercepts YouTube navigation and redirects to no-cookie version

const STORAGE_KEY = 'enabled';

// Initialize extension state
chrome.runtime.onInstalled.addListener(async () => {
  console.log('[FreeYT] Extension installed');

  // Set default state to enabled
  const result = await chrome.storage.local.get(STORAGE_KEY);
  if (result[STORAGE_KEY] === undefined) {
    await chrome.storage.local.set({ [STORAGE_KEY]: true });
    console.log('[FreeYT] Initialized as enabled');
  }
});

// Check if URL is a video URL
function isVideoURL(url) {
  try {
    const urlObj = new URL(url);
    console.log('[FreeYT] Checking URL:', url, 'hostname:', urlObj.hostname, 'pathname:', urlObj.pathname);
    
    // Don't process if already converted to no-cookie version
    if (urlObj.hostname.includes('yout-ube.com')) {
      console.log('[FreeYT] URL already converted to no-cookie version');
      return false;
    }
    
    return (
      (urlObj.hostname.includes('youtube.com') && (
        urlObj.pathname.includes('/watch') ||
        urlObj.pathname.includes('/shorts/') ||
        urlObj.pathname.includes('/embed/') ||
        urlObj.pathname.includes('/live/')
      )) ||
      urlObj.hostname === 'youtu.be'
    );
  } catch (e) {
    console.error('[FreeYT] Error parsing URL:', e);
    return false;
  }
}

// Convert YouTube URL to no-cookie version
function convertToNoCookie(url) {
  console.log('[FreeYT] Attempting to convert URL:', url);
  if (isVideoURL(url)) {
    const converted = url.replace(/youtube/g, 'yout-ube');
    console.log('[FreeYT] Converted:', url, '→', converted);
    return converted;
  }
  console.log('[FreeYT] URL is not a video URL, skipping conversion');
  return null;
}

// Intercept navigation requests
chrome.webNavigation.onBeforeNavigate.addListener(async (details) => {
  // Only handle main frame navigations
  if (details.frameId !== 0) return;

  console.log('[FreeYT] onBeforeNavigate triggered for:', details.url);

  // Check if extension is enabled
  const { [STORAGE_KEY]: enabled = true } = await chrome.storage.local.get(STORAGE_KEY);
  if (!enabled) {
    console.log('[FreeYT] Extension disabled, skipping redirect');
    return;
  }

  const noCookieUrl = convertToNoCookie(details.url);

  if (noCookieUrl && noCookieUrl !== details.url) {
    console.log('[FreeYT] Redirecting:', details.url, '→', noCookieUrl);
    chrome.tabs.update(details.tabId, { url: noCookieUrl });
  }
}, {
  url: [
    { hostContains: 'youtube.com' },
    { hostEquals: 'youtu.be' }
  ]
});

// Also listen for history state updates (for YouTube's AJAX navigation)
chrome.webNavigation.onHistoryStateUpdated.addListener(async (details) => {
  // Only handle main frame navigations
  if (details.frameId !== 0) return;

  console.log('[FreeYT] onHistoryStateUpdated triggered for:', details.url);

  // Check if extension is enabled
  const { [STORAGE_KEY]: enabled = true } = await chrome.storage.local.get(STORAGE_KEY);
  if (!enabled) {
    console.log('[FreeYT] Extension disabled, skipping redirect');
    return;
  }

  const noCookieUrl = convertToNoCookie(details.url);

  if (noCookieUrl && noCookieUrl !== details.url) {
    console.log('[FreeYT] Redirecting via history update:', details.url, '→', noCookieUrl);
    chrome.tabs.update(details.tabId, { url: noCookieUrl });
  }
}, {
  url: [
    { hostContains: 'youtube.com' },
    { hostEquals: 'youtu.be' }
  ]
});

// Handle messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log('[FreeYT] Received message:', request);

  if (request.action === 'getState') {
    chrome.storage.local.get(STORAGE_KEY).then(result => {
      sendResponse({ enabled: result[STORAGE_KEY] ?? true });
    });
    return true;
  }

  return false;
});

console.log('[FreeYT] Background service worker initialized');
