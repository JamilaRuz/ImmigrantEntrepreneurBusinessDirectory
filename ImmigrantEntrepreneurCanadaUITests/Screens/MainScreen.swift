//
//  MainScreen.swift
//  WomenBusinessDirectoryUITests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import XCTest

/// A screen object representing the main screen of the app
struct MainScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - UI Elements
    
    /// The main navigation title
    var navigationTitle: XCUIElement {
        app.navigationBars.element(boundBy: 0).staticTexts.element(boundBy: 0)
    }
    
    /// The list of entrepreneurs (assuming it's a list/table view)
    var entrepreneursList: XCUIElement {
        app.tables.firstMatch
    }
    
    /// Search field (if available)
    var searchField: XCUIElement {
        app.searchFields.firstMatch
    }
    
    // MARK: - Actions
    
    /// Taps on an entrepreneur with the given name
    /// - Parameter name: The name of the entrepreneur to tap on
    /// - Returns: true if the entrepreneur was found and tapped, false otherwise
    func tapEntrepreneur(named name: String) -> Bool {
        let cell = app.cells.staticTexts[name]
        if cell.exists {
            cell.tap()
            return true
        }
        return false
    }
    
    /// Searches for an entrepreneur
    /// - Parameter searchText: The text to search for
    func search(for searchText: String) {
        searchField.tap()
        searchField.typeText(searchText)
    }
    
    /// Waits for the screen to load
    /// - Parameter timeout: The maximum time to wait
    /// - Returns: true if the screen loaded within the timeout, false otherwise
    func waitForScreenToLoad(timeout: TimeInterval = 5) -> Bool {
        return entrepreneursList.waitForExistence(timeout: timeout)
    }
} 