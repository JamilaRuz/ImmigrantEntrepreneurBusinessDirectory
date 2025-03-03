//
//  WomenBusinessDirectoryUITests.swift
//  WomenBusinessDirectoryUITests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import XCTest

class WomenBusinessDirectoryUITests: XCTestCase {
    // Setup can be handled with lifecycle hooks if needed
    
    func testAppLaunchAndMainScreen() throws {
        // Launch the app using our helper
        let app = XCUIApplication()
        app.launch()
        
        // Create the main screen flow
        let entrepreneurListFlow = EntrepreneurListFlow(app: app)
        
        // Verify the main screen loads correctly
        XCTAssertTrue(entrepreneurListFlow.verifyScreenLoads())
    }
    
    func testSearchFunctionality() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Create the main screen flow
        let entrepreneurListFlow = EntrepreneurListFlow(app: app)
        
        // Wait for the screen to load
        XCTAssertTrue(entrepreneurListFlow.verifyScreenLoads())
        
        // Test search with a term that should return results
        // Note: You'll need to adjust this based on your actual data
        XCTAssertTrue(entrepreneurListFlow.searchForEntrepreneur(searchText: "Test", expectingResults: true))
        
        // Test search with a term that should not return results
        XCTAssertTrue(entrepreneurListFlow.searchForEntrepreneur(searchText: "ZZZZZZZ", expectingResults: false))
    }
    
    func testEntrepreneurDetailNavigation() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Create the main screen flow
        let entrepreneurListFlow = EntrepreneurListFlow(app: app)
        
        // Wait for the screen to load
        XCTAssertTrue(entrepreneurListFlow.verifyScreenLoads())
        
        // Test tapping on an entrepreneur and navigating to detail
        // Note: You'll need to adjust the name based on your actual data
        XCTAssertTrue(entrepreneurListFlow.tapEntrepreneurAndVerifyDetailScreen(named: "Test Entrepreneur"))
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
