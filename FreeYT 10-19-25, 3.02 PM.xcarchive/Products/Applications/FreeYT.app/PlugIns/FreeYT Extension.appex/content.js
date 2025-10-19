// FreeYT Content Script
// Redirects YouTube URLs to no-cookie versions by inserting hyphen

(async function() {
  'use strict';

  console.log('[FreeYT] Content script loaded on:', window.location.href);

  // Check if extension is enabled
  async function isEnabled() {
    try {
      const result = await chrome.storage.local.get('enabled');
      return result.enabled !== false; // Default to true
    } catch (e) {
      console.log('[FreeYT] Storage not available, defaulting to enabled');
      return true;
    }
  }

  // Convert YouTube URL to no-cookie version (youtube → yout-ube)
  // Only for actual video URLs, not homepage or browse pages
  function convertToNoCookie(url) {
    try {
      const urlObj = new URL(url);
      console.log('[FreeYT] Content script checking URL:', url, 'hostname:', urlObj.hostname, 'pathname:', urlObj.pathname);

      // Don't process if already converted to no-cookie version
      if (urlObj.hostname.includes('yout-ube.com')) {
        console.log('[FreeYT] URL already converted to no-cookie version');
        return null;
      }

      // Check if it's a video URL
      const isVideo =
        (urlObj.hostname.includes('youtube.com') && (
          urlObj.pathname.includes('/watch') ||       // youtube.com/watch?v=xxx
          urlObj.pathname.includes('/shorts/') ||     // youtube.com/shorts/xxx
          urlObj.pathname.includes('/embed/') ||      // youtube.com/embed/xxx
          urlObj.pathname.includes('/live/')          // youtube.com/live/xxx
        )) ||
        urlObj.hostname === 'youtu.be';               // youtu.be/xxx

      console.log('[FreeYT] Is video URL:', isVideo);

      if (isVideo) {
        // Simply replace "youtube" with "yout-ube" in the URL
        const converted = url.replace(/youtube/g, 'yout-ube');
        console.log('[FreeYT] Content script converted:', url, '→', converted);
        return converted;
      }
    } catch (e) {
      console.error('[FreeYT] Error parsing URL:', e);
    }
    return null;
  }

  // Main redirect logic
  async function handleRedirect() {
    const enabled = await isEnabled();
    if (!enabled) {
      console.log('[FreeYT] Extension disabled, skipping redirect');
      return;
    }

    const currentUrl = window.location.href;
    const noCookieUrl = convertToNoCookie(currentUrl);

    if (noCookieUrl && noCookieUrl !== currentUrl) {
      console.log('[FreeYT] Redirecting to:', noCookieUrl);
      window.location.replace(noCookieUrl);
      return true; // Indicate we redirected
    }
    return false; // No redirect needed
  }

  // Monitor URL changes for YouTube's dynamic navigation
  let lastUrl = window.location.href;
  let isRedirecting = false;
  
  function checkForUrlChange() {
    if (isRedirecting) return; // Avoid checking during our own redirect
    
    const currentUrl = window.location.href;
    if (currentUrl !== lastUrl) {
      console.log('[FreeYT] URL changed from', lastUrl, 'to', currentUrl);
      lastUrl = currentUrl;
      
      // Small delay to let YouTube finish loading
      setTimeout(async () => {
        if (!isRedirecting) {
          isRedirecting = true;
          const didRedirect = await handleRedirect();
          if (!didRedirect) {
            isRedirecting = false;
          }
        }
      }, 100);
    }
  }

  // Listen for popstate events (back/forward navigation)
  window.addEventListener('popstate', () => {
    console.log('[FreeYT] popstate event detected');
    setTimeout(checkForUrlChange, 50);
  });

  // Listen for pushstate/replacestate (YouTube's navigation)
  const originalPushState = history.pushState;
  const originalReplaceState = history.replaceState;
  
  history.pushState = function() {
    originalPushState.apply(history, arguments);
    console.log('[FreeYT] pushState detected');
    setTimeout(checkForUrlChange, 50);
  };
  
  history.replaceState = function() {
    originalReplaceState.apply(history, arguments);
    console.log('[FreeYT] replaceState detected');
    setTimeout(checkForUrlChange, 50);
  };

  // Use MutationObserver to detect when YouTube changes content
  const observer = new MutationObserver(() => {
    checkForUrlChange();
  });

  // Start observing changes to the page title and head (YouTube updates these)
  if (document.head) {
    observer.observe(document.head, {
      childList: true,
      subtree: true
    });
  }

  // Also check periodically in case other methods miss something
  setInterval(checkForUrlChange, 2000);

  // Run on page load (initial check)
  setTimeout(async () => {
    isRedirecting = true;
    const didRedirect = await handleRedirect();
    if (!didRedirect) {
      isRedirecting = false;
    }
  }, 100);

  console.log('[FreeYT] Content script initialized with enhanced URL monitoring');
})();
