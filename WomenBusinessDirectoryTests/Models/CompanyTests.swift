//
//  CompanyTests.swift
//  WomenBusinessDirectoryTests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import Testing
@testable import WomenBusinessDirectory

// Create a mock Company for testing
private struct MockCompany {
    let id: String
    let name: String
    let email: String
}

struct CompanyTests {
    @Test
    func testCompanyInitialization() {
        // Using a mock company for basic testing
        let mockCompany = MockCompany(id: "123", name: "Test Company", email: "test@example.com")
        #expect(mockCompany.id == "123")
        #expect(mockCompany.name == "Test Company")
        #expect(mockCompany.email == "test@example.com")
        
        // Test the actual Company model with the correct initializer
        let company = Company(
            companyId: "123",
            entrepId: "test-entrep",
            categoryIds: [],
            name: "Test Company",
            logoImg: nil,
            headerImg: nil,
            aboutUs: "About us text",
            dateFounded: "2023-01-01",
            portfolioImages: [],
            address: "123 Test St",
            city: "Test City",
            phoneNum: "123-456-7890",
            email: "test@example.com",
            workHours: "Mon-Fri 9-5",
            services: ["Service 1", "Service 2"],
            socialMedia: nil,
            businessModel: .online,
            website: "www.test.com",
            ownershipTypes: [.femaleOwned],
            isBookmarked: false
        )
        
        #expect(company.companyId == "123")
        #expect(company.name == "Test Company")
        #expect(company.email == "test@example.com")
    }
    
    // Setup and teardown can be handled with @Suite and lifecycle hooks if needed
    
    @Test
    func testExample() async throws {
        // This is an example of a functional test case.
        // Use #expect to verify your tests produce the correct results.
    }
    
    @Test
    func testPerformanceExample() async throws {
        // Performance testing can be done with #benchmark in Swift Testing
        // Example:
        // #benchmark("Performance test") {
        //     // Code to benchmark
        // }
    }
}
