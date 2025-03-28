//
//  TestDataGenerator.swift
//  WomenBusinessDirectoryTests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import Foundation
import FirebaseFirestore
@testable import WomenBusinessDirectory

/// Utility class to generate test data for performance testing
/// This class is part of the test target and not included in production builds
class TestDataGenerator {
    
    /// Generate a specified number of test companies
    /// - Parameter count: The number of companies to generate
    /// - Returns: An array of Company objects
    static func generateTestCompanies(count: Int) -> [Company] {
        var companies: [Company] = []
        
        for i in 1...count {
            let company = Company(
                companyId: "perf-test-\(i)",
                entrepId: "entrep-\(i % 10 + 1)",
                categoryIds: ["cat1", "cat2"],
                name: "Performance Test Company \(i)",
                logoImg: "https://example.com/logo\(i % 5 + 1).jpg",
                headerImg: "https://example.com/header\(i % 5 + 1).jpg",
                aboutUs: "This is a test company for performance testing. It has a reasonably long description to simulate real-world data with various lengths of text that might affect layout performance during scrolling. The description includes multiple sentences to ensure we're testing with realistic content.",
                dateFounded: "2020-01-\(i % 28 + 1)",
                portfolioImages: [
                    "https://example.com/portfolio\(i % 10 + 1)_1.jpg",
                    "https://example.com/portfolio\(i % 10 + 1)_2.jpg",
                    "https://example.com/portfolio\(i % 10 + 1)_3.jpg"
                ],
                address: "\(i*100) Test Street",
                city: ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"][i % 5],
                phoneNum: "555-\(1000 + i)",
                email: "company\(i)@example.com",
                workHours: "Mon-Fri 9-5",
                services: [
                    "Service \(i % 3 + 1)",
                    "Service \(i % 5 + 1)",
                    "Service \(i % 7 + 1)"
                ],
                socialMedia: [
                    .facebook: "facebook.com/test\(i)",
                    .instagram: "instagram.com/test\(i)",
                    .linkedin: "linkedin.com/test\(i)"
                ],
                businessModel: [.online, .offline, .hybrid][i % 3],
                website: "www.testcompany\(i).com",
                ownershipTypes: [
                    [.femaleOwned, .lgbtqOwned],
                    [.asianOwned, .femaleOwned],
                    [.blackOwned],
                    [.latinxOwned, .lgbtqOwned],
                    [.veteranOwned]
                ][i % 5],
                isBookmarked: false
            )
            companies.append(company)
        }
        
        return companies
    }
    
    /// Helper method to load test companies into a view model for testing
    /// - Parameters:
    ///   - viewModel: The view model to load data into
    ///   - count: The number of test companies to generate
    static func loadTestCompaniesIntoViewModel(_ viewModel: CompaniesListViewModel, count: Int) {
        let companies = generateTestCompanies(count: count)
        
        // Use reflection to set the companies
        let mirror = Mirror(reflecting: viewModel)
        if let companiesProperty = mirror.children.first(where: { $0.label == "companies" }) {
            if let companiesPropertyAddress = withUnsafePointer(to: companiesProperty.value, { $0 }) {
                let bindableCompanies = companiesPropertyAddress.withMemoryRebound(to: Published<[Company]>.self, capacity: 1) { $0 }
                if let companiesSetter = bindableCompanies.pointee.projectedValue.setter {
                    companiesSetter(companies)
                }
            }
        }
    }
    
    /// Helper method to load test companies and categories into DirectoryListViewModel
    /// - Parameters:
    ///   - viewModel: The DirectoryListViewModel to load data into
    ///   - count: The number of test companies to generate
    static func loadTestDataIntoDirectoryViewModel(_ viewModel: DirectoryListViewModel, count: Int) {
        let testCategory = Category(id: "perf-test", name: "Performance Test", systemIconName: "speedometer")
        let testCompanies = generateTestCompanies(count: count)
        
        // Set categories using reflection
        let mirror = Mirror(reflecting: viewModel)
        if let categoriesProperty = mirror.children.first(where: { $0.label == "categories" }) {
            if let categoriesPropertyAddress = withUnsafePointer(to: categoriesProperty.value, { $0 }) {
                let bindableCategories = categoriesPropertyAddress.withMemoryRebound(to: Published<[Category]>.self, capacity: 1) { $0 }
                if let categoriesSetter = bindableCategories.pointee.projectedValue.setter {
                    categoriesSetter([testCategory])
                }
            }
        }
        
        // Set companies using reflection
        if let companiesProperty = mirror.children.first(where: { $0.label == "allCompanies" }) {
            if let companiesPropertyAddress = withUnsafePointer(to: companiesProperty.value, { $0 }) {
                let bindableCompanies = companiesPropertyAddress.withMemoryRebound(to: Published<[Company]>.self, capacity: 1) { $0 }
                if let companiesSetter = bindableCompanies.pointee.projectedValue.setter {
                    companiesSetter(testCompanies)
                }
            }
        }
        
        // Set loading to false using reflection
        if let loadingProperty = mirror.children.first(where: { $0.label == "isLoading" }) {
            if let loadingPropertyAddress = withUnsafePointer(to: loadingProperty.value, { $0 }) {
                let bindableLoading = loadingPropertyAddress.withMemoryRebound(to: Published<Bool>.self, capacity: 1) { $0 }
                if let loadingSetter = bindableLoading.pointee.projectedValue.setter {
                    loadingSetter(false)
                }
            }
        }
    }
    
    // MARK: - Firebase Test Data for XCUITests only
    
    /// Upload test companies to Firebase for UI testing
    /// WARNING: This should only be used in test environments
    static func uploadTestCompaniesToFirebase(count: Int, completion: @escaping (Error?) -> Void) {
        let companies = generateTestCompanies(count: count)
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Create a test collection to avoid polluting real data
        let testCollection = db.collection("test_companies")
        
        // Clear existing test data first
        testCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting existing test documents: \(error)")
                completion(error)
                return
            }
            
            // Delete existing documents
            let deleteBatch = db.batch()
            snapshot?.documents.forEach { document in
                deleteBatch.deleteDocument(testCollection.document(document.documentID))
            }
            
            // Commit deletion batch
            deleteBatch.commit { error in
                if let error = error {
                    print("Error deleting existing test documents: \(error)")
                    completion(error)
                    return
                }
                
                // Now add new test companies
                for company in companies {
                    let docRef = testCollection.document(company.companyId)
                    do {
                        try batch.setData(from: company, forDocument: docRef)
                    } catch {
                        print("Error encoding company: \(error)")
                        completion(error)
                        return
                    }
                }
                
                // Commit the batch
                batch.commit { error in
                    if let error = error {
                        print("Error committing batch: \(error)")
                    } else {
                        print("Successfully uploaded \(count) test companies to Firebase")
                    }
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Performance Measurement for UITests
    
    /// Helper function to measure frame rate during scrolling
    static func measureFrameRate(during seconds: TimeInterval, completion: @escaping (Double) -> Void) {
        var frameCount = 0
        var lastTimestamp: CFTimeInterval = 0
        var displayLink: CADisplayLink?
        
        class DisplayLinkTarget: NSObject {
            var frameCount = 0
            var lastTimestamp: CFTimeInterval = 0
            var duration: TimeInterval
            var completion: (Double) -> Void
            var displayLink: CADisplayLink?
            
            init(duration: TimeInterval, completion: @escaping (Double) -> Void) {
                self.duration = duration
                self.completion = completion
                super.init()
            }
            
            @objc func handleDisplayLink(_ link: CADisplayLink) {
                if lastTimestamp == 0 {
                    lastTimestamp = link.timestamp
                    return
                }
                
                frameCount += 1
                
                let elapsed = link.timestamp - lastTimestamp
                if elapsed >= duration {
                    let fps = Double(frameCount) / elapsed
                    displayLink?.invalidate()
                    completion(fps)
                }
            }
        }
        
        let target = DisplayLinkTarget(duration: seconds, completion: completion)
        displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.handleDisplayLink(_:)))
        target.displayLink = displayLink
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Conceptual implementation of a frame rate measurement
    /// This would be implemented in a UI test, not in the app itself
    static func measureFrameRateConceptual() -> String {
        // This would be implemented in UITests with XCUIApplication
        return """
        // Example XCUITest implementation
        func testScrollingPerformance() {
            let app = XCUIApplication()
            app.launch()
            
            // Navigate to list view
            app.tabBars.buttons["Directory"].tap()
            
            // Start performance metrics
            let metric = XCTOSSignpostMetric.scrollingAndResponsiveness
            measure(metrics: [metric]) {
                // Perform scrolling action
                let list = app.tables.firstMatch
                let start = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
                let finish = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
                start.press(forDuration: 0.01, thenDragTo: finish)
            }
        }
        """
    }
} 