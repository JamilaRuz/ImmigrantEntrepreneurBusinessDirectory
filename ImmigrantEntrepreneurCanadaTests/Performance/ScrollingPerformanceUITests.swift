//
//  ScrollingPerformanceUITests.swift
//  WomenBusinessDirectoryUITests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import XCTest

/**
 This file demonstrates how to properly implement performance testing in UI tests
 without compromising production code.
 
 The key principles are:
 1. All test code stays in the test target
 2. Use launch arguments to signal test mode
 3. Keep test data generators in the test target
 4. Production code only needs minimal hooks to respond to test signals
 */
class ScrollingPerformanceUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    /// Test scrolling performance with 50 companies
    func testScrollingPerformanceWith50Companies() throws {
        let app = XCUIApplication()
        
        // Configure the app for testing with command line arguments
        // Note: This requires minimal debug-only hooks in the production code
        app.launchArguments = ["-UITesting", "-LoadTestData", "-CompanyCount", "50"]
        app.launch()
        
        // Navigate to the directory list view
        app.tabBars.buttons["Directory"].tap()
        
        // Wait for the data to load
        let predicate = NSPredicate(format: "exists == true")
        let firstRow = app.tables.cells.element(boundBy: 0)
        expectation(for: predicate, evaluatedWith: firstRow, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Perform the scrolling test with metrics
        let metrics = XCTOSSignpostMetric.scrollingAndResponsiveness
        measure(metrics: [metrics]) {
            // Find the table view
            let table = app.tables.firstMatch
            
            // Scroll down
            let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let end = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            start.press(forDuration: 0.01, thenDragTo: end)
            
            // Short pause for stabilization
            Thread.sleep(forTimeInterval: 0.5)
            
            // Scroll back up
            end.press(forDuration: 0.01, thenDragTo: start)
        }
    }
    
    /// Test scrolling with image loading
    func testScrollingWithImageLoading() throws {
        let app = XCUIApplication()
        
        // Configure app to clear image caches and load test data
        app.launchArguments = ["-UITesting", "-LoadTestData", "-CompanyCount", "50", "-ClearImageCache"]
        app.launch()
        
        // Navigate to the directory list view
        app.tabBars.buttons["Directory"].tap()
        
        // Wait for the data to load
        let predicate = NSPredicate(format: "exists == true")
        let firstRow = app.tables.cells.element(boundBy: 0)
        expectation(for: predicate, evaluatedWith: firstRow, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Select a category to see companies with images
        firstRow.tap()
        
        // Measure scrolling performance while images are loading
        let metrics = XCTOSSignpostMetric.scrollingAndResponsiveness
        measure(metrics: [metrics]) {
            // Find the collection/table view
            let list = app.collectionViews.firstMatch
            
            // Scroll down slowly to trigger image loading
            let start = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let end = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            
            // Slow drag to ensure images load during scroll
            start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)
        }
    }
}

// MARK: - Example AppDelegate Implementation

/**
 This is an example of what you would add to your AppDelegate to support UITesting
 without compromising production code. This is just an example and NOT actually used.
 
 The actual implementation would go in your app's AppDelegate.swift.
 */
class AppDelegateExample {
    
    static let sampleAppDelegateCode = """
    // In your AppDelegate.swift
    
    #if DEBUG
    /// Setup for UI Testing mode when launched with specific arguments
    private func setupUITestingIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments
        
        // Check if we're in UI testing mode
        if arguments.contains("-UITesting") {
            // Set up test data if needed
            if arguments.contains("-LoadTestData") {
                // Get company count
                var companyCount = 50 // Default
                if let countIndex = arguments.firstIndex(of: "-CompanyCount"),
                   countIndex + 1 < arguments.count,
                   let count = Int(arguments[countIndex + 1]) {
                    companyCount = count
                }
                
                // Clear image cache if requested
                if arguments.contains("-ClearImageCache") {
                    ImageCache.shared.clearCache()
                }
                
                // Load test data - NOTE: We're not using a TestDataGenerator from test target,
                // but instead have a simpler version in the app itself
                setupTestData(companyCount: companyCount)
            }
        }
    }
    
    /// Generate test companies for UI Testing
    private func setupTestData(companyCount: Int) {
        // Create test companies (simplified from what would be in TestDataGenerator)
        var testCompanies: [Company] = []
        
        for i in 1...companyCount {
            let company = Company(
                companyId: "test-\(i)",
                name: "Test Company \(i)",
                // Other properties with minimal test data
                isBookmarked: false
            )
            testCompanies.append(company)
        }
        
        // Store in a singleton accessible to view models
        TestDataProvider.shared.testCompanies = testCompanies
        TestDataProvider.shared.testingEnabled = true
        
        print("📱 App configured for UI Testing with \(companyCount) test companies")
    }
    #endif
    
    // In your application(_:didFinishLaunchingWithOptions:) method:
    #if DEBUG
    setupUITestingIfNeeded()
    #endif
    """
} 