//
//  TestProviderExample.swift
//  WomenBusinessDirectoryTests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import Foundation
@testable import WomenBusinessDirectory

/**
 This file provides an example implementation of a test data provider for the app.
 
 This is NOT an actual implementation, but rather an example of how to properly
 implement test data support in the app without including test code in production.
 
 Key principles:
 1. This is only available in DEBUG builds
 2. It provides a clean API for production code to use
 3. It doesn't require including test-specific code like TestDataGenerator
 4. It's controlled via launch arguments
 
 In a real implementation, you would use a similar approach but modify it for your
 specific app architecture.
 */

// Sample implementation of what would be in your production app
#if DEBUG
/// Simple provider for test data in DEBUG builds only
class TestDataProvider {
    /// Singleton instance
    static let shared = TestDataProvider()
    
    /// Flag to indicate if testing mode is enabled
    var testingEnabled = false
    
    /// Test companies for UI testing
    var testCompanies: [Company] = []
    
    /// Test entrepreneurs for UI testing
    var testEntrepreneurs: [Entrepreneur] = []
    
    /// Test categories for UI testing
    var testCategories: [Category] = []
    
    private init() {}
    
    /// Check if test data should be used for a given view model
    func shouldUseTestData() -> Bool {
        return testingEnabled && ProcessInfo.processInfo.arguments.contains("-UITesting")
    }
}

// Extension to show how a view model would use this
extension DirectoryListViewModel {
    /// Example method for how a ViewModel would check for test data
    func loadDataWithTestSupport() {
        #if DEBUG
        // Check if we should use test data
        if TestDataProvider.shared.shouldUseTestData() {
            // Use test data instead of real data
            self.categories = TestDataProvider.shared.testCategories
            self.allCompanies = TestDataProvider.shared.testCompanies
            self.isLoading = false
            print("📊 Loaded test data instead of real data")
            return
        }
        #endif
        
        // Normal data loading code would continue here
        // loadData()
    }
}
#endif

/**
 This is sample implementation code for the `AppDelegate.swift` file.
 
 It demonstrates how to add minimal hooks to properly support UI testing
 without compromising production code or including test-specific code like
 TestDataGenerator in the production app.
 */
class AppDelegateExample {
    
    static let sampleAppDelegateCode = """
    // Add to your AppDelegate.swift:
    
    #if DEBUG
    /// Setup UI testing if needed based on launch arguments
    private func setupForUITesting() {
        let arguments = ProcessInfo.processInfo.arguments
        
        // Check if UI testing is enabled
        if arguments.contains("-UITesting") {
            print("📱 UI Testing mode enabled")
            
            // Check if we should load test data
            if arguments.contains("-LoadTestData") {
                // Get company count
                var companyCount = 50 // Default count
                if let countIndex = arguments.firstIndex(of: "-CompanyCount"),
                   countIndex + 1 < arguments.count,
                   let count = Int(arguments[countIndex + 1]) {
                    companyCount = count
                }
                
                // Set up test data for company directory
                setupTestData(companyCount: companyCount)
                
                // Set up other test conditions
                if arguments.contains("-ClearImageCache") {
                    // Clear image cache for testing image loading performance
                    ImageLoader.shared.clearCache()
                }
            }
        }
    }
    
    /// Create test data for UI testing
    private func setupTestData(companyCount: Int) {
        // Create test categories
        let testCategories = [
            Category(id: "test-cat-1", name: "Test Category 1", systemIconName: "briefcase"),
            Category(id: "test-cat-2", name: "Test Category 2", systemIconName: "bag")
        ]
        
        // Create test companies - much simpler than TestDataGenerator in test target
        var testCompanies: [Company] = []
        for i in 1...companyCount {
            // Create a basic test company 
            let company = Company(
                companyId: "test-\(i)",
                entrepId: "test-entrep-\(i % 5)",
                categoryIds: i % 2 == 0 ? ["test-cat-1"] : ["test-cat-2"],
                name: "Test Company \(i)",
                logoImg: "https://example.com/test\(i).jpg",
                aboutUs: "Test description for company \(i)",
                city: ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"][i % 5],
                // Add minimal required properties
                isBookmarked: false
            )
            testCompanies.append(company)
        }
        
        // Configure test data provider
        TestDataProvider.shared.testCategories = testCategories
        TestDataProvider.shared.testCompanies = testCompanies
        TestDataProvider.shared.testingEnabled = true
        
        print("📊 Set up \(companyCount) test companies for performance testing")
    }
    #endif
    
    // In application(_:didFinishLaunchingWithOptions:):
    #if DEBUG
    setupForUITesting()
    #endif
    """
} 