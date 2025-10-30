//
//  OnboardingManager.swift
//  FreeYT
//
//  Created by Assistant on 10/30/25.
//

import Foundation
import UIKit

/// Manages the onboarding flow and user preferences for FreeYT
class OnboardingManager {
    
    static let shared = OnboardingManager()
    
    private init() {}
    
    // MARK: - User Defaults Keys
    
    private enum UserDefaultsKey {
        static let hasLaunchedBefore = "HasLaunchedBefore"
        static let hasCompletedOnboarding = "HasCompletedOnboarding"
        static let lastExtensionCheckDate = "LastExtensionCheckDate"
        static let onboardingCompletionDate = "OnboardingCompletionDate"
    }
    
    // MARK: - Onboarding State
    
    /// Returns true if this is the user's first time opening the app
    var isFirstLaunch: Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaultsKey.hasLaunchedBefore)
    }
    
    /// Returns true if the user has completed the full onboarding process
    var hasCompletedOnboarding: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.hasCompletedOnboarding)
    }
    
    /// Marks the app as having been launched
    func markAppAsLaunched() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasLaunchedBefore)
    }
    
    /// Marks onboarding as completed
    func markOnboardingAsCompleted() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasCompletedOnboarding)
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.onboardingCompletionDate)
    }
    
    /// Returns the date when onboarding was completed, if available
    var onboardingCompletionDate: Date? {
        return UserDefaults.standard.object(forKey: UserDefaultsKey.onboardingCompletionDate) as? Date
    }
    
    // MARK: - Extension Status Tracking
    
    /// Updates the last time we checked the extension status
    func updateLastExtensionCheckDate() {
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.lastExtensionCheckDate)
    }
    
    /// Returns the last date we checked extension status
    var lastExtensionCheckDate: Date? {
        return UserDefaults.standard.object(forKey: UserDefaultsKey.lastExtensionCheckDate) as? Date
    }
    
    /// Returns true if we should check extension status (hasn't been checked recently)
    var shouldCheckExtensionStatus: Bool {
        guard let lastCheck = lastExtensionCheckDate else { return true }
        return Date().timeIntervalSince(lastCheck) > 10.0 // Check every 10 seconds
    }
    
    // MARK: - Onboarding Analytics
    
    /// Returns helpful analytics about the onboarding process
    func getOnboardingAnalytics() -> [String: Any] {
        var analytics: [String: Any] = [:]
        
        analytics["isFirstLaunch"] = isFirstLaunch
        analytics["hasCompletedOnboarding"] = hasCompletedOnboarding
        
        if let completionDate = onboardingCompletionDate {
            analytics["onboardingCompletionDate"] = completionDate
            analytics["daysSinceOnboarding"] = Calendar.current.dateComponents([.day], from: completionDate, to: Date()).day ?? 0
        }
        
        if let lastCheckDate = lastExtensionCheckDate {
            analytics["lastExtensionCheckDate"] = lastCheckDate
            analytics["minutesSinceLastCheck"] = Int(Date().timeIntervalSince(lastCheckDate) / 60)
        }
        
        return analytics
    }
    
    // MARK: - Reset (for testing)
    
    /// Resets all onboarding state (useful for testing)
    func resetOnboardingState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserDefaultsKey.hasLaunchedBefore)
        defaults.removeObject(forKey: UserDefaultsKey.hasCompletedOnboarding)
        defaults.removeObject(forKey: UserDefaultsKey.lastExtensionCheckDate)
        defaults.removeObject(forKey: UserDefaultsKey.onboardingCompletionDate)
    }
}

// MARK: - Notifications

extension OnboardingManager {
    
    /// Notification names for onboarding events
    enum Notification {
        static let onboardingCompleted = NSNotification.Name("OnboardingCompleted")
        static let extensionStatusChanged = NSNotification.Name("ExtensionStatusChanged")
    }
    
    /// Posts a notification when onboarding is completed
    func notifyOnboardingCompleted() {
        NotificationCenter.default.post(name: Notification.onboardingCompleted, object: nil)
    }
    
    /// Posts a notification when extension status changes
    func notifyExtensionStatusChanged(isEnabled: Bool) {
        NotificationCenter.default.post(
            name: Notification.extensionStatusChanged, 
            object: nil, 
            userInfo: ["isEnabled": isEnabled]
        )
    }
}