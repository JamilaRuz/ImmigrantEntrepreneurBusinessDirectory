//
//  WomenBusinessDirectoryUITestsLaunchTests.swift
//  WomenBusinessDirectoryUITests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import XCTest

class WomenBusinessDirectoryUITestsLaunchTests: XCTestCase {
    // In XCTest, we use class properties for configuration
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        // Take a screenshot
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Verify the app launched successfully
        XCTAssertTrue(app.exists)
    }
}
