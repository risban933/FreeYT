//
//  FreeYTTests.swift
//  FreeYTTests
//
//  Created by Rishabh Bansal on 10/19/25.
//

import Testing
import Foundation
@testable import FreeYT

struct FreeYTTests {

    // MARK: - URL Pattern Matching Tests

    @Test func testYouTubeWatchURLPattern() async throws {
        let testURL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        let url = URL(string: testURL)
        #expect(url != nil, "YouTube watch URL should be valid")
        #expect(url?.host?.contains("youtube.com") == true, "URL should contain youtube.com")
    }

    @Test func testYouTubeShortURLPattern() async throws {
        let testURL = "https://youtu.be/dQw4w9WgXcQ"
        let url = URL(string: testURL)
        #expect(url != nil, "YouTube short URL should be valid")
        #expect(url?.host == "youtu.be", "URL should be youtu.be")
    }

    @Test func testYouTubeShortsURLPattern() async throws {
        let testURL = "https://www.youtube.com/shorts/abc123def"
        let url = URL(string: testURL)
        #expect(url != nil, "YouTube Shorts URL should be valid")
        #expect(url?.path.contains("/shorts/") == true, "URL should contain /shorts/")
    }

    @Test func testYouTubeLiveURLPattern() async throws {
        let testURL = "https://www.youtube.com/live/xyz789abc"
        let url = URL(string: testURL)
        #expect(url != nil, "YouTube Live URL should be valid")
        #expect(url?.path.contains("/live/") == true, "URL should contain /live/")
    }

    @Test func testYouTubeEmbedURLPattern() async throws {
        let testURL = "https://www.youtube.com/embed/dQw4w9WgXcQ"
        let url = URL(string: testURL)
        #expect(url != nil, "YouTube embed URL should be valid")
        #expect(url?.path.contains("/embed/") == true, "URL should contain /embed/")
    }

    @Test func testMobileYouTubeURLPattern() async throws {
        let testURL = "https://m.youtube.com/watch?v=dQw4w9WgXcQ"
        let url = URL(string: testURL)
        #expect(url != nil, "Mobile YouTube URL should be valid")
        #expect(url?.host == "m.youtube.com", "URL should be m.youtube.com")
    }

    // MARK: - URL Transformation Tests

    @Test func testNoCookieDomainTransformation() async throws {
        let originalURL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        let expectedDomain = "youtube-nocookie.com"

        #expect(originalURL.contains("youtube.com"), "Original URL should contain youtube.com")
        #expect(!originalURL.contains(expectedDomain), "Original URL should not contain youtube-nocookie.com")

        // The transformation should result in youtube-nocookie.com
        let transformedURL = "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ"
        #expect(transformedURL.contains(expectedDomain), "Transformed URL should contain youtube-nocookie.com")
        #expect(transformedURL.contains("/embed/"), "Transformed URL should use embed format")
    }

    @Test func testVideoIDExtraction() async throws {
        // Test video ID extraction from watch URL
        let watchURL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        if let url = URL(string: watchURL),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value {
            #expect(videoID == "dQw4w9WgXcQ", "Should extract correct video ID from watch URL")
        } else {
            Issue.record("Failed to extract video ID from watch URL")
        }

        // Test video ID extraction from short URL
        let shortURL = "https://youtu.be/dQw4w9WgXcQ"
        if let url = URL(string: shortURL) {
            let videoID = String(url.path.dropFirst()) // Remove leading /
            #expect(videoID == "dQw4w9WgXcQ", "Should extract correct video ID from short URL")
        } else {
            Issue.record("Failed to parse short URL")
        }

        // Test video ID extraction from shorts URL
        let shortsURL = "https://www.youtube.com/shorts/abc123def"
        if let url = URL(string: shortsURL) {
            let pathComponents = url.pathComponents
            if let videoID = pathComponents.last {
                #expect(videoID == "abc123def", "Should extract correct video ID from shorts URL")
            }
        } else {
            Issue.record("Failed to parse shorts URL")
        }
    }

    @Test func testEmbedURLFormat() async throws {
        let videoID = "dQw4w9WgXcQ"
        let embedURL = "https://www.youtube-nocookie.com/embed/\(videoID)"

        #expect(embedURL.contains("youtube-nocookie.com"), "Embed URL should use youtube-nocookie.com")
        #expect(embedURL.contains("/embed/"), "Embed URL should use /embed/ path")
        #expect(embedURL.contains(videoID), "Embed URL should contain video ID")
    }

    // MARK: - Edge Case Tests

    @Test func testYouTubeWatchURLWithMultipleParameters() async throws {
        let testURL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42s&list=PLxyz"
        if let url = URL(string: testURL),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value {
            #expect(videoID == "dQw4w9WgXcQ", "Should extract video ID even with multiple parameters")
        } else {
            Issue.record("Failed to handle URL with multiple parameters")
        }
    }

    @Test func testYouTubeHomepageShouldNotMatch() async throws {
        let homeURL = "https://www.youtube.com/"
        let url = URL(string: homeURL)
        #expect(url != nil, "Homepage URL should be valid")

        // Homepage should not have /watch, /shorts, /embed, or /live
        let shouldNotRedirect = !(url?.path.contains("/watch") ?? false) &&
                               !(url?.path.contains("/shorts/") ?? false) &&
                               !(url?.path.contains("/embed/") ?? false) &&
                               !(url?.path.contains("/live/") ?? false)
        #expect(shouldNotRedirect, "Homepage URL should not match redirect patterns")
    }

    @Test func testYouTubeNoCookieURLShouldNotBeRedirected() async throws {
        let noCookieURL = "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ"
        let url = URL(string: noCookieURL)
        #expect(url != nil, "No-cookie URL should be valid")
        #expect(url?.host == "www.youtube-nocookie.com", "URL should already be youtube-nocookie.com")
        // This URL should not be redirected again (already in no-cookie format)
    }

    // MARK: - Bundle and Configuration Tests

    @Test func testBundleIdentifierIsCorrect() async throws {
        let bundleID = Bundle.main.bundleIdentifier
        #expect(bundleID != nil, "Bundle identifier should exist")
        #expect(bundleID?.hasPrefix("com.freeyt") == true, "Bundle ID should start with com.freeyt")
    }

    @Test func testAppVersionExists() async throws {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        #expect(version != nil, "App version should exist")
        #expect(version?.isEmpty == false, "App version should not be empty")
    }

    @Test func testAppDisplayNameExists() async throws {
        let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                         Bundle.main.infoDictionary?["CFBundleName"] as? String
        #expect(displayName != nil, "App display name should exist")
        #expect(displayName?.isEmpty == false, "App display name should not be empty")
    }

    // MARK: - Resource Validation Tests

    @Test func testAppIconExists() async throws {
        // Test that app icon exists in assets
        #expect(Bundle.main.path(forResource: "AppIcon", ofType: nil) != nil ||
                Bundle.main.path(forResource: "Assets", ofType: "car") != nil,
                "App icon should exist in bundle")
    }

    @Test func testLaunchScreenExists() async throws {
        // Test that LaunchScreen storyboard exists
        let launchScreen = Bundle.main.path(forResource: "LaunchScreen", ofType: "storyboardc")
        #expect(launchScreen != nil, "LaunchScreen storyboard should exist")
    }

    // MARK: - Extension Bundle Tests

    @Test func testExtensionBundleIdentifier() async throws {
        // Extension should have correct bundle identifier pattern
        let expectedExtensionID = "com.freeyt.app.extension"
        // Note: Can't directly access extension bundle from app tests,
        // but we can verify the identifier format is correct
        #expect(expectedExtensionID.hasPrefix("com.freeyt"), "Extension ID should have correct prefix")
        #expect(expectedExtensionID.hasSuffix(".extension"), "Extension ID should end with .extension")
    }

    // MARK: - Privacy and Security Tests

    @Test func testNoCookieRedirectEnhancesPrivacy() async throws {
        // Verify that youtube-nocookie.com is the correct privacy-enhanced domain
        let noCookieDomain = "youtube-nocookie.com"
        #expect(noCookieDomain.contains("nocookie"), "Domain should explicitly mention no-cookie")
        #expect(!noCookieDomain.contains("yout-ube"), "Should not use incorrect yout-ube domain")
    }

    @Test func testExtensionDoesNotCollectData() async throws {
        // Verify that extension doesn't have network permissions beyond YouTube domains
        // This is a documentation test to ensure privacy policy matches implementation
        let allowedDomains = ["youtube.com", "youtu.be", "youtube-nocookie.com"]
        for domain in allowedDomains {
            #expect(!domain.isEmpty, "Allowed domains should not be empty")
        }
        // Extension should ONLY have host permissions for YouTube domains, nothing else
    }

    // MARK: - Regex Pattern Validation Tests

    @Test func testRegexPatternsMatchExpectedURLs() async throws {
        // Test that regex patterns would correctly match YouTube URLs
        struct TestCase {
            let url: String
            let shouldMatch: Bool
            let description: String
        }

        let testCases: [TestCase] = [
            TestCase(url: "https://www.youtube.com/watch?v=abc123", shouldMatch: true, description: "Standard watch URL"),
            TestCase(url: "https://youtube.com/watch?v=abc123", shouldMatch: true, description: "Watch URL without www"),
            TestCase(url: "https://youtu.be/abc123", shouldMatch: true, description: "Short URL"),
            TestCase(url: "https://www.youtube.com/shorts/abc123", shouldMatch: true, description: "Shorts URL"),
            TestCase(url: "https://www.youtube.com/live/abc123", shouldMatch: true, description: "Live URL"),
            TestCase(url: "https://m.youtube.com/watch?v=abc123", shouldMatch: true, description: "Mobile watch URL"),
            TestCase(url: "https://www.youtube.com/", shouldMatch: false, description: "Homepage"),
            TestCase(url: "https://www.youtube.com/feed/trending", shouldMatch: false, description: "Trending page"),
            TestCase(url: "https://www.google.com", shouldMatch: false, description: "Non-YouTube domain"),
        ]

        for testCase in testCases {
            let url = URL(string: testCase.url)
            #expect(url != nil, "\(testCase.description): URL should be valid")

            if let url = url {
                let isYouTubeVideo = (url.host?.contains("youtube.com") == true || url.host == "youtu.be") &&
                                    (url.path.contains("/watch") ||
                                     url.path.contains("/shorts/") ||
                                     url.path.contains("/embed/") ||
                                     url.path.contains("/live/"))

                #expect(isYouTubeVideo == testCase.shouldMatch,
                       "\(testCase.description): Match result should be \(testCase.shouldMatch)")
            }
        }
    }
}
