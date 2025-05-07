//
//  EntrepreneurListFlow.swift
//  WomenBusinessDirectoryUITests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import XCTest

/// A test flow for the entrepreneur list screen
struct EntrepreneurListFlow {
    private let app: XCUIApplication
    private let mainScreen: MainScreen
    
    init(app: XCUIApplication) {
        self.app = app
        self.mainScreen = MainScreen(app: app)
    }
    
    /// Verifies that the entrepreneur list screen loads correctly
    /// - Returns: true if the screen loaded successfully, false otherwise
    func verifyScreenLoads() -> Bool {
        return mainScreen.waitForScreenToLoad()
    }
    
    /// Searches for an entrepreneur and verifies the results
    /// - Parameters:
    ///   - searchText: The text to search for
    ///   - expectedResults: Whether results are expected to be found
    /// - Returns: true if the search results match expectations, false otherwise
    func searchForEntrepreneur(searchText: String, expectingResults: Bool) -> Bool {
        mainScreen.search(for: searchText)
        
        // Give the search time to complete
        _ = UITestHelpers.wait(timeout: 2) { true }
        
        // Check if there are cells in the list
        let hasCells = app.cells.count > 0
        return hasCells == expectingResults
    }
    
    /// Taps on an entrepreneur and verifies navigation to detail screen
    /// - Parameter name: The name of the entrepreneur to tap on
    /// - Returns: true if navigation was successful, false otherwise
    func tapEntrepreneurAndVerifyDetailScreen(named name: String) -> Bool {
        guard mainScreen.tapEntrepreneur(named: name) else {
            return false
        }
        
        // Wait for detail screen to appear (assuming it has a specific element)
        // This would need to be adjusted based on your actual UI
        return UITestHelpers.wait {
            // Check for an element that would only be on the detail screen
            // For example, a specific label or button
            return self.app.staticTexts["Contact Information"].exists
        }
    }
} 