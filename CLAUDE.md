# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FreeYT is a **production-ready** Safari Web Extension for iOS/macOS that automatically redirects YouTube URLs to privacy-enhanced no-cookie embed versions (youtube-nocookie.com). The extension protects user privacy by preventing YouTube tracking cookies.

### Components

1. **FreeYT App** - Native iOS/Mac Catalyst host app with polished UI
2. **FreeYT Extension** - Safari Web Extension (Manifest V3) with declarativeNetRequest-based redirects
3. **Features**:
   - Automatic YouTube → youtube-nocookie.com redirection
   - Toggle extension on/off via Safari toolbar popup
   - Beautiful dark/light mode UI
   - Extension status indicator in host app
   - Comprehensive URL pattern matching

## Architecture

### Two-Component Structure

The extension uses Safari's Manifest V3 architecture with declarative net request rules rather than traditional Safari App Extension APIs:

- **Host App (FreeYT/)**: Minimal iOS app that serves as a container for the extension. Contains a WebView-based UI (`ViewController.swift`) that loads `Main.html` to instruct users to enable the extension in Safari settings.

- **Extension (FreeYT Extension/)**: Contains all extension logic via:
  - `manifest.json` - Extension configuration with declarativeNetRequest permissions
  - `rules.json` - Redirect rules using regex patterns to transform YouTube URLs
  - `background.js` and `content.js` - Minimal message passing stubs (mostly unused in current implementation)
  - `SafariWebExtensionHandler.swift` - Empty placeholder class (legacy Safari App Extension APIs are not used)

### URL Redirect Logic

The extension uses 5 declarative rules in `FreeYT Extension/Resources/rules.json`:

1. Rule 1: `youtube.com/watch?v=...` → `youtube-nocookie.com/embed/...`
2. Rule 2: `youtu.be/...` → `youtube-nocookie.com/embed/...`
3. Rule 3: `youtube.com/shorts/...` → `youtube-nocookie.com/embed/...`
4. Rule 4: `m.youtube.com/watch?v=...` → `youtube-nocookie.com/embed/...`
5. Rule 5: `youtube.com/embed/...` → `youtube-nocookie.com/embed/...` (ensures already-embedded URLs use no-cookie)

All rules operate on `main_frame` resource types only.

### Bundle Identifiers (Production-Ready)

The app uses consistent bundle IDs across all files:
- Host app: `com.freeyt.app`
- Extension: `com.freeyt.app.extension`
- Extension identifier in AppDelegate.swift matches Info.plist

**Ready for distribution** - Bundle identifiers are consistent across:
- FreeYT/Info.plist
- FreeYT Extension/Info.plist
- FreeYT/AppDelegate.swift:22

## Building and Running

### Build the Project (Verified Working)

```bash
# Build for iOS Simulator (tested and working)
xcodebuild -project FreeYT.xcodeproj -scheme FreeYT -destination 'platform=iOS Simulator,name=iPhone 16' clean build

# Build for Mac Catalyst
xcodebuild -project FreeYT.xcodeproj -scheme FreeYT -destination 'platform=macOS,variant=Mac Catalyst' build

# Clean build folder
xcodebuild clean -project FreeYT.xcodeproj -scheme FreeYT
```

**Status**: ✅ Builds successfully with no errors

### Running Tests

```bash
# Run unit tests
xcodebuild test -project FreeYT.xcodeproj -scheme FreeYT -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -project FreeYT.xcodeproj -scheme FreeYT -only-testing:FreeYTTests
xcodebuild test -project FreeYT.xcodeproj -scheme FreeYT -only-testing:FreeYTUITests
```

### Opening in Xcode

```bash
open FreeYT.xcodeproj
```

## Project Structure

```
FreeYT/
├── FreeYT.xcodeproj/          # Xcode project file
├── FreeYT/                    # Host iOS app
│   ├── AppDelegate.swift      # App lifecycle, extension state checking
│   ├── SceneDelegate.swift    # Scene configuration
│   ├── ViewController.swift   # WebView controller for Main.html
│   ├── Info.plist            # App configuration
│   ├── Resources/
│   │   └── Base.lproj/Main.html  # User instructions HTML
│   ├── popup.html/css/js     # Extension popup UI (in host app dir)
│   └── Assets.xcassets/      # App icons and assets
├── FreeYT Extension/          # Safari Web Extension
│   ├── SafariWebExtensionHandler.swift  # No-op placeholder
│   ├── Info.plist            # Extension configuration
│   └── Resources/
│       ├── manifest.json     # Extension manifest (Manifest V3)
│       ├── rules.json        # Declarative net request rules
│       ├── background.js     # Minimal background script
│       ├── content.js        # Minimal content script
│       ├── popup.html/css/js # Extension popup (duplicate in Resources/)
│       └── _locales/en/      # Localization strings
├── FreeYTTests/              # Unit tests
└── FreeYTUITests/            # UI tests
```

## Key Files and Their Purpose

### Extension Core Logic

- **manifest.json** - Extension configuration with permissions, icons, action popup, and background service worker
- **rules.json** - 5 declarativeNetRequest rules for redirecting YouTube URLs
- **background.js** - Service worker that manages rule enabling/disabling based on user toggle
- **popup.html/css/js** - Safari toolbar popup UI with toggle switch and test buttons

### Host App

- **ViewController.swift** - Modern UIKit-based UI showing extension status and enable instructions
- **AppDelegate.swift** - Checks extension state on Mac Catalyst
- **LaunchScreen.storyboard** - Polished splash screen with icon, title, and subtitle
- **Assets.xcassets/AppIcon** - Contains 1024x1024 app icon (properly sized)

### How the Extension Works

1. **Declarative Rules**: Uses `declarativeNetRequest` API for efficient URL redirects
2. **User Control**: Background service worker enables/disables rules based on storage
3. **No Content Scripts**: All redirects happen at the network level (faster, more private)
4. **Comprehensive Coverage**: Handles youtube.com, youtu.be, m.youtube.com, shorts, embeds

## Mac Catalyst Support

The app includes Mac Catalyst support with extension state checking in `AppDelegate.swift`. On Mac, the app checks if the Safari Web Extension is enabled and logs status to console. This requires:

- `#if targetEnvironment(macCatalyst)` compilation conditions
- `SFSafariWebExtensionManager` API (iOS 15.0+)
- Correct extension identifier matching the bundle ID

## Production-Ready Status ✅

### What's Complete

- ✅ **Manifest V3 implementation** with declarativeNetRequest
- ✅ **Functional toggle popup** with enable/disable and test buttons
- ✅ **Background service worker** for dynamic rule management
- ✅ **Comprehensive redirect rules** covering all YouTube URL patterns
- ✅ **Polished UI** with dark/light mode support
- ✅ **Proper app icon** (1024x1024, all sizes configured)
- ✅ **Beautiful launch screen** with branding
- ✅ **Bundle ID consistency** across all files
- ✅ **Extension state detection** for Mac Catalyst
- ✅ **Clean codebase** (duplicates removed)
- ✅ **Builds successfully** with no errors or warnings

### Testing the Extension

1. Build and run the FreeYT app on iOS Simulator or Mac:
   ```bash
   xcodebuild -project FreeYT.xcodeproj -scheme FreeYT -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```

2. Open Safari Settings → Extensions

3. Enable "FreeYT - Privacy YouTube" extension

4. Test redirects:
   - Click "Test: YouTube Video" in the popup
   - Navigate to `https://youtube.com/watch?v=xxx`
   - Should redirect to `https://youtube-nocookie.com/embed/xxx`

5. Toggle on/off in Safari toolbar popup to enable/disable redirects

### Extension Popup Features

- **Toggle Switch**: Enable/disable YouTube redirects
- **Status Indicator**: Shows enabled/disabled state with color coding
- **Test Buttons**: Open sample YouTube URLs to verify redirects work
- **Beautiful Design**: Modern dark/light mode UI with smooth animations

### For App Store Submission

Before submitting to App Store, update:
1. Bundle IDs in Xcode project settings (currently using `com.freeyt.app`)
2. App Store Connect metadata and screenshots
3. Privacy policy (extension doesn't collect any data)
4. App review notes explaining the extension's privacy benefits
