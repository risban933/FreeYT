# Privacy Policy for FreeYT - Privacy YouTube

**Last Updated:** November 13, 2025

## Overview

FreeYT - Privacy YouTube is a Safari Web Extension designed to enhance your privacy when browsing YouTube. This privacy policy explains how our extension works, what data it accesses, and our commitment to protecting your privacy.

## Our Privacy Commitment

**We do not collect, store, transmit, or sell any of your personal data.** FreeYT is built with privacy as its core principle.

## What Our Extension Does

FreeYT automatically redirects YouTube URLs to privacy-enhanced no-cookie embed versions:

- Converts `youtube.com/watch?v=xxx` to `youtube-nocookie.com/embed/xxx`
- Converts `youtu.be/xxx` to `youtube-nocookie.com/embed/xxx`
- Converts `youtube.com/shorts/xxx` to `youtube-nocookie.com/embed/xxx`
- Converts `youtube.com/live/xxx` to `youtube-nocookie.com/embed/xxx`
- Converts `m.youtube.com/watch?v=xxx` to `youtube-nocookie.com/embed/xxx`

This redirection prevents YouTube from setting tracking cookies on your device, protecting your privacy.

## Data Collection

**FreeYT collects ZERO data.**

Specifically:

- ✅ **No personal information collected** - We don't collect names, emails, addresses, or any identifying information
- ✅ **No browsing history collected** - We don't track which videos you watch or websites you visit
- ✅ **No cookies or tracking** - We don't set any cookies or use any tracking technologies
- ✅ **No analytics or telemetry** - We don't send any usage statistics or crash reports
- ✅ **No user accounts** - No login, no account creation, no user profiles
- ✅ **No third-party services** - We don't integrate with any third-party analytics or advertising services
- ✅ **No data sharing** - Since we collect no data, we have nothing to share with third parties

## Permissions Explained

FreeYT requests the following permissions to function:

### 1. **declarativeNetRequest**
- **Purpose:** Allows the extension to redirect YouTube URLs at the network level
- **Data Access:** None - operates on URL patterns only, no content inspection
- **Privacy Impact:** Zero - no data is collected or transmitted

### 2. **declarativeNetRequestFeedback**
- **Purpose:** Allows the extension to check if redirect rules are working
- **Data Access:** Rule activation status only
- **Privacy Impact:** Zero - no user data involved

### 3. **storage**
- **Purpose:** Stores your extension enable/disable preference
- **Data Stored:** Single boolean value (enabled: true/false)
- **Location:** Stored locally on your device only
- **Privacy Impact:** Zero - never transmitted anywhere

### 4. **Host Permissions** (`*://*.youtube.com/*`, `*://youtu.be/*`)
- **Purpose:** Allows the extension to detect and redirect YouTube URLs
- **Data Access:** URL patterns only - no page content access
- **Privacy Impact:** Zero - only URL matching, no data collection

## How FreeYT Works

FreeYT uses Safari's declarativeNetRequest API, which means:

1. **Network-Level Redirection:** URLs are redirected before the page even loads
2. **No Content Access:** The extension never reads or modifies page content
3. **No Scripts Injected:** No JavaScript is injected into web pages
4. **Completely Local:** All processing happens on your device
5. **No Network Requests:** The extension never makes any network requests to external servers

## Data Storage

The **only** data stored by FreeYT is:

- **Extension State:** A single boolean value indicating whether the extension is enabled or disabled
- **Storage Location:** Local device storage only (never synced or transmitted)
- **Data Size:** Less than 1 KB
- **Data Retention:** Stored until you uninstall the extension or clear Safari data

## Third-Party Access

- **No third-party access** - The extension does not communicate with any external servers
- **No data sharing** - Since no data is collected, there is nothing to share
- **No advertising** - The extension is completely ad-free

## YouTube-NoCooki.com Domain

FreeYT redirects to `youtube-nocookie.com`, which is YouTube's official no-cookie domain operated by Google. This domain:

- Is operated by YouTube/Google
- Serves the same video content without tracking cookies
- Is subject to YouTube's privacy policy (not ours, as we don't operate this domain)
- See [YouTube's Privacy Policy](https://policies.google.com/privacy) for details on their data practices

**Important:** While FreeYT prevents YouTube tracking cookies, youtube-nocookie.com is still operated by Google. We recommend reviewing Google's privacy policy for complete information.

## Children's Privacy

FreeYT does not collect any data from anyone, including children under 13. The extension is appropriate for users of all ages.

## Security

Since FreeYT collects no data and makes no network requests, there is no data to secure or transmit. The extension:

- Operates entirely locally on your device
- Uses Safari's built-in security features
- Never transmits any information over the network
- Has no attack surface for data breaches

## Changes to This Policy

We may update this privacy policy from time to time. We will notify users of any material changes by:

- Updating the "Last Updated" date at the top of this policy
- Posting the new policy on our GitHub repository

We encourage you to review this policy periodically.

## Open Source

FreeYT is open source software. You can review the complete source code at:

**GitHub Repository:** https://github.com/risban933/FreeYT

Our code is transparent and independently verifiable. Anyone can audit the source code to confirm our privacy claims.

## Contact Information

If you have questions about this privacy policy or FreeYT's privacy practices, you can:

- Open an issue on our GitHub repository: https://github.com/risban933/FreeYT/issues
- Review the source code: https://github.com/risban933/FreeYT

## Your Rights

Since FreeYT collects no personal data:

- There is no data to access, modify, or delete
- There are no data processing activities to opt out of
- There is no data to export or transfer

You can uninstall the extension at any time through Safari Settings > Extensions.

## Compliance

### GDPR (European Union)

FreeYT complies with the General Data Protection Regulation (GDPR) because:

- We process no personal data
- We have no lawful basis requirement (no data processing)
- Users have no data subject rights to exercise (no data exists)

### CCPA (California)

FreeYT complies with the California Consumer Privacy Act (CCPA) because:

- We collect no personal information
- We sell no personal information
- We share no personal information

### Other Jurisdictions

Since FreeYT collects no data, it complies with privacy regulations worldwide.

## Technical Details

For technical users interested in how FreeYT works:

### Manifest V3 Architecture
- Uses declarativeNetRequest API (network-level redirects)
- No content scripts injected into pages
- No background scripts with broad permissions
- Minimal permission set

### Redirect Rules
- 6 regex-based redirect rules defined in `rules.json`
- Rules operate on main_frame requests only
- Pattern matching happens locally without data collection
- Rules can be enabled/disabled via popup toggle

### Storage Implementation
- Uses `chrome.storage.local` API
- Stores single key-value pair: `{ "enabled": true/false }`
- No sync storage (stays on device)
- No storage quotas exceeded (< 1 KB)

### Network Activity
- **Zero network requests** made by the extension
- All redirects are URL transformations (no network lookup)
- No analytics endpoints
- No crash reporting endpoints
- No update checks (handled by Safari)

## Verification

To verify our privacy claims:

1. **Review Source Code:** All code is available on GitHub
2. **Inspect Network Traffic:** Use Safari's developer tools to verify no network requests
3. **Check Permissions:** Review requested permissions in Safari Settings
4. **Audit Storage:** Inspect `chrome.storage.local` - only one boolean value
5. **Monitor Behavior:** The extension only modifies URLs, nothing else

## Summary

**FreeYT - Privacy YouTube is a zero-data-collection extension.**

- ✅ No data collection
- ✅ No tracking
- ✅ No analytics
- ✅ No third-party services
- ✅ No network requests
- ✅ No cookies
- ✅ Fully local operation
- ✅ Open source and auditable

Your privacy is our priority. We built FreeYT to enhance your privacy, not compromise it.

---

**Questions?** Open an issue on our GitHub repository: https://github.com/risban933/FreeYT/issues

**Last Updated:** November 13, 2025
