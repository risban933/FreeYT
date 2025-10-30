//
//  FreeYTTests.swift
//  FreeYTTests
//
//  Created by Rishabh Bansal on 10/19/25.
//

import XCTest
@testable import FreeYT

final class FreeYTTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset state before each test
        OnboardingManager.shared.resetOnboardingState()
    }

    func testFirstLaunchDetection() {
        let manager = OnboardingManager.shared
        
        // Should be first launch when no data is stored
        XCTAssertTrue(manager.isFirstLaunch, "Should detect first launch when no previous data exists")
        
        // Mark as launched
        manager.markAppAsLaunched()
        
        // Should no longer be first launch
        XCTAssertFalse(manager.isFirstLaunch, "Should not be first launch after marking as launched")
    }
    
    func testOnboardingCompletion() {
        let manager = OnboardingManager.shared
        
        // Initially should not be completed
        XCTAssertFalse(manager.hasCompletedOnboarding, "Onboarding should not be completed initially")
        XCTAssertNil(manager.onboardingCompletionDate, "Should not have completion date initially")
        
        // Mark as completed
        manager.markOnboardingAsCompleted()
        
        // Should now be completed
        XCTAssertTrue(manager.hasCompletedOnboarding, "Onboarding should be marked as completed")
        
        guard let completionDate = manager.onboardingCompletionDate else {
            XCTFail("Should have a completion date after marking as completed")
            return
        }
        
        // Completion date should be recent (within last minute)
        let timeSinceCompletion = Date().timeIntervalSince(completionDate)
        XCTAssertLessThan(timeSinceCompletion, 60, "Completion date should be recent")
    }
    
    func testExtensionStatusTiming() {
        let manager = OnboardingManager.shared
        
        // Should check status initially
        XCTAssertTrue(manager.shouldCheckExtensionStatus, "Should check extension status when no previous check exists")
        
        // Update check date
        manager.updateLastExtensionCheckDate()
        
        // Should not check immediately after updating
        XCTAssertFalse(manager.shouldCheckExtensionStatus, "Should not check extension status immediately after update")
        
        // Verify last check date is set
        guard let lastCheck = manager.lastExtensionCheckDate else {
            XCTFail("Should have a last check date after updating")
            return
        }
        
        let timeSinceCheck = Date().timeIntervalSince(lastCheck)
        XCTAssertLessThan(timeSinceCheck, 5, "Last check date should be very recent")
    }
    
    func testDebouncerExecutesActionAfterDelay() {
        let debouncer = Debouncer()
        let expectation = self.expectation(description: "Debounced action should execute")
        var executed = false
        
        debouncer.call(delay: .milliseconds(100)) {
            executed = true
            expectation.fulfill()
        }
        
        // Should not be executed immediately
        XCTAssertFalse(executed, "Action should not execute immediately")
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(executed, "Action should execute after delay")
    }
    
    func testDebouncerCancelsEarlierActions() {
        let debouncer = Debouncer()
        let firstExpectation = expectation(description: "First action should not execute")
        firstExpectation.isInverted = true
        
        let secondExpectation = expectation(description: "Second action should execute")
        
        var firstExecuted = false
        var secondExecuted = false
        
        // First call
        debouncer.call(delay: .milliseconds(200)) {
            firstExecuted = true
            firstExpectation.fulfill()
        }
        
        // Second call should cancel the first
        debouncer.call(delay: .milliseconds(100)) {
            secondExecuted = true
            secondExpectation.fulfill()
        }
        
        wait(for: [firstExpectation, secondExpectation], timeout: 1.0)
        
        XCTAssertFalse(firstExecuted, "First action should be cancelled")
        XCTAssertTrue(secondExecuted, "Second action should execute")
    }
    
    func testAnalytics() {
        let manager = OnboardingManager.shared
        
        // Set up some state
        manager.markAppAsLaunched()
        manager.markOnboardingAsCompleted()
        manager.updateLastExtensionCheckDate()
        
        let analytics = manager.getOnboardingAnalytics()
        
        // Verify analytics contain expected keys
        XCTAssertNotNil(analytics["isFirstLaunch"], "Analytics should contain isFirstLaunch")
        XCTAssertNotNil(analytics["hasCompletedOnboarding"], "Analytics should contain hasCompletedOnboarding")
        XCTAssertNotNil(analytics["onboardingCompletionDate"], "Analytics should contain onboardingCompletionDate")
        XCTAssertNotNil(analytics["daysSinceOnboarding"], "Analytics should contain daysSinceOnboarding")
        XCTAssertNotNil(analytics["lastExtensionCheckDate"], "Analytics should contain lastExtensionCheckDate")
        XCTAssertNotNil(analytics["minutesSinceLastCheck"], "Analytics should contain minutesSinceLastCheck")
        
        // Verify analytics values are correct types
        XCTAssertEqual(analytics["isFirstLaunch"] as? Bool, false, "isFirstLaunch should be false after marking as launched")
        XCTAssertEqual(analytics["hasCompletedOnboarding"] as? Bool, true, "hasCompletedOnboarding should be true after completion")
        XCTAssertEqual(analytics["daysSinceOnboarding"] as? Int, 0, "daysSinceOnboarding should be 0 for today")
    }
    
    func testReset() {
        let manager = OnboardingManager.shared
        
        // Set up some state
        manager.markAppAsLaunched()
        manager.markOnboardingAsCompleted()
        manager.updateLastExtensionCheckDate()
        
        // Verify state exists
        XCTAssertFalse(manager.isFirstLaunch, "Should not be first launch before reset")
        XCTAssertTrue(manager.hasCompletedOnboarding, "Should have completed onboarding before reset")
        XCTAssertNotNil(manager.lastExtensionCheckDate, "Should have check date before reset")
        
        // Reset
        manager.resetOnboardingState()
        
        // Verify state is cleared
        XCTAssertTrue(manager.isFirstLaunch, "Should be first launch after reset")
        XCTAssertFalse(manager.hasCompletedOnboarding, "Should not have completed onboarding after reset")
        XCTAssertNil(manager.lastExtensionCheckDate, "Should not have check date after reset")
        XCTAssertNil(manager.onboardingCompletionDate, "Should not have completion date after reset")
    }
    
    func testNotificationPosting() {
        let manager = OnboardingManager.shared
        
        // Set up expectation for onboarding completion notification
        let onboardingExpectation = expectation(forNotification: OnboardingManager.Notification.onboardingCompleted, object: nil)
        
        // Trigger onboarding completion
        manager.notifyOnboardingCompleted()
        
        // Wait for notification
        wait(for: [onboardingExpectation], timeout: 1.0)
        
        // Test extension status notification
        let extensionExpectation = expectation(forNotification: OnboardingManager.Notification.extensionStatusChanged, object: nil)
        
        // Trigger extension status change
        manager.notifyExtensionStatusChanged(isEnabled: true)
        
        // Wait for notification
        wait(for: [extensionExpectation], timeout: 1.0)
    }
}
