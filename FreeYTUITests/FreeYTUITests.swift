//
//  FreeYTUITests.swift
//  FreeYTUITests
//
//  Created by Rishabh Bansal on 10/19/25.
//

import XCTest

final class FreeYTUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Test that the main onboarding screen appears
        let titleLabel = app.staticTexts["FreeYT"]
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 5), "App title should appear")
        
        let settingsButton = app.buttons["Open Safari Settings"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        
        let searchDemoButton = app.buttons["Try Search Demo"]
        XCTAssertTrue(searchDemoButton.exists, "Search demo button should exist")
    }
    
    func testSearchDemoAccess() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Tap search demo button
        let searchDemoButton = app.buttons["Try Search Demo"]
        XCTAssertTrue(searchDemoButton.waitForExistence(timeout: 5), "Search demo button should exist")
        
        searchDemoButton.tap()
        
        // Verify search demo opens
        let searchTitle = app.navigationBars["Search Demo"]
        XCTAssertTrue(searchTitle.waitForExistence(timeout: 3), "Search demo should open")
    }
    
    func testSearchBarInteraction() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to search demo
        let searchDemoButton = app.buttons["Try Search Demo"]
        searchDemoButton.tap()
        
        // Wait for search demo to load
        let searchTitle = app.navigationBars["Search Demo"]
        XCTAssertTrue(searchTitle.waitForExistence(timeout: 3), "Search demo should open")
        
        // Find the search field - trying different selectors since SwiftUI may render differently
        var searchField: XCUIElement?
        
        // Try different ways to find the search field
        let textFields = app.textFields
        for field in textFields.allElementsBoundByIndex {
            if field.placeholderValue?.contains("Search") == true || 
               field.value as? String == "Search YouTube content..." {
                searchField = field
                break
            }
        }
        
        // If still not found, try the first text field
        if searchField == nil && textFields.count > 0 {
            searchField = textFields.firstMatch
        }
        
        guard let field = searchField else {
            XCTFail("Could not find search field")
            return
        }
        
        // Test typing in search field
        field.tap()
        field.typeText("privacy")
        
        // Wait a moment for UI updates
        Thread.sleep(forTimeInterval: 0.5)
        
        // Test clear functionality if available
        let clearButton = app.buttons.matching(identifier: "Clear").firstMatch
        if clearButton.exists {
            clearButton.tap()
        }
    }
    
    func testAccessibility() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test main screen accessibility
        let titleLabel = app.staticTexts["FreeYT"]
        XCTAssertTrue(titleLabel.exists, "Title should be accessible")
        
        let settingsButton = app.buttons["Open Safari Settings"]
        XCTAssertTrue(settingsButton.isHittable, "Settings button should be hittable")
        
        let searchDemoButton = app.buttons["Try Search Demo"]
        XCTAssertTrue(searchDemoButton.isHittable, "Search demo button should be hittable")
        
        // Test search demo accessibility
        searchDemoButton.tap()
        
        // Wait for navigation
        Thread.sleep(forTimeInterval: 1)
        
        // Check if search elements are accessible
        let textFields = app.textFields
        if textFields.count > 0 {
            let searchField = textFields.firstMatch
            XCTAssertTrue(searchField.isHittable, "Search field should be hittable")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
