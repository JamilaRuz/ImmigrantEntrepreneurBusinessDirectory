//
//  UITestHelpers.swift
//  WomenBusinessDirectoryUITests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import XCTest

/// Helper functions for UI testing
enum UITestHelpers {
    /// Launches the app with the given launch arguments and returns the application instance
    /// - Parameters:
    ///   - launchArguments: Optional launch arguments to pass to the app
    /// - Returns: The launched XCUIApplication instance
    static func launchApp(withArguments launchArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        
        // Add any default launch arguments here
        var arguments = ["UI-TESTING"]
        arguments.append(contentsOf: launchArguments)
        
        app.launchArguments = arguments
        app.launch()
        
        return app
    }
    
    /// Takes a screenshot and returns it
    /// - Parameters:
    ///   - app: The application instance
    ///   - name: A name for the screenshot
    /// - Returns: The screenshot image
    static func takeScreenshot(of app: XCUIApplication, named name: String) -> XCUIScreenshot {
        let screenshot = app.screenshot()
        // In a real implementation, you might want to save this screenshot somewhere
        return screenshot
    }
    
    /// Waits for a condition to be true with a timeout
    /// - Parameters:
    ///   - timeout: The maximum time to wait
    ///   - condition: The condition to check
    /// - Returns: true if the condition became true within the timeout, false otherwise
    static func wait(timeout: TimeInterval = 5, for condition: @escaping () -> Bool) -> Bool {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                return true
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        
        return condition()
    }
    
    /// Taps the back button in the navigation bar
    /// - Parameter app: The application instance
    static func tapBackButton(in app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
} 