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
        // Create a company with all required properties
        let company = Company(
            companyId: "test-id",
            entrepId: "test-entrep",
            categoryIds: ["cat1", "cat2"],
            name: "Test Company",
            logoImg: "logo.png",
            headerImg: "header.png",
            aboutUs: "This is a test company",
            dateFounded: "2023-01-01",
            portfolioImages: ["portfolio1.jpg", "portfolio2.jpg"],
            address: "123 Test St",
            city: "Test City",
            phoneNum: "123-456-7890",
            email: "test@example.com",
            workHours: "Mon-Fri 9-5",
            services: ["Service 1", "Service 2"],
            socialMedias: [.facebook: "facebook.com/test", .linkedin: "linkedin.com/test"],
            businessModel: .online,
            website: "www.test.com",
            ownershipTypes: [.femaleOwned, .lgbtqOwned],
            isBookmarked: false
        )
        
        // Verify properties are set correctly
        #expect(company.companyId == "test-id")
        #expect(company.entrepId == "test-entrep")
        #expect(company.categoryIds == ["cat1", "cat2"])
        #expect(company.name == "Test Company")
        #expect(company.logoImg == "logo.png")
        #expect(company.headerImg == "header.png")
        #expect(company.aboutUs == "This is a test company")
        #expect(company.dateFounded == "2023-01-01")
        #expect(company.portfolioImages.count == 2)
        #expect(company.address == "123 Test St")
        #expect(company.city == "Test City")
        #expect(company.phoneNum == "123-456-7890")
        #expect(company.email == "test@example.com")
        #expect(company.workHours == "Mon-Fri 9-5")
        #expect(company.services == ["Service 1", "Service 2"])
        #expect(company.socialMedias?[.facebook] == "facebook.com/test")
        #expect(company.businessModel == .online)
        #expect(company.website == "www.test.com")
        #expect(company.ownershipTypes.count == 2)
        #expect(company.bookmarkedBy.isEmpty)
    }
    
    @Test
    func testSocialMediaComputed() {
        // Test company with social media
        let companyWithSocial = Company(
            companyId: "test-id",
            entrepId: "test-entrep",
            categoryIds: [],
            name: "Test Company",
            logoImg: nil,
            headerImg: nil,
            aboutUs: "",
            dateFounded: "",
            portfolioImages: [],
            address: "",
            city: "",
            phoneNum: "",
            email: "",
            workHours: "",
            services: [],
            socialMedias: [.facebook: "fb", .twitter: "tw", .linkedin: "li"],
            businessModel: .online,
            website: "",
            ownershipTypes: []
        )
        
        // Test socialMedias computed property
        #expect(companyWithSocial.socialMediaPlatforms.count == 3)
        #expect(companyWithSocial.socialMediaPlatforms.contains(.facebook))
        #expect(companyWithSocial.socialMediaPlatforms.contains(.twitter))
        #expect(companyWithSocial.socialMediaPlatforms.contains(.linkedin))
        
        // Test company without social media
        let companyWithoutSocial = Company(
            companyId: "test-id",
            entrepId: "test-entrep",
            categoryIds: [],
            name: "Test Company",
            logoImg: nil,
            headerImg: nil,
            aboutUs: "",
            dateFounded: "",
            portfolioImages: [],
            address: "",
            city: "",
            phoneNum: "",
            email: "",
            workHours: "",
            services: [],
            socialMedias: nil,
            businessModel: .online,
            website: "",
            ownershipTypes: []
        )
        
        // Test socialMedias computed property with nil socialMedia
        #expect(companyWithoutSocial.socialMediaPlatforms.isEmpty)
    }
    
    @Test
    func testCompanyEquality() {
        // Create two companies with the same ID but different properties
        let company1 = Company(
            companyId: "same-id",
            entrepId: "entrep1",
            categoryIds: [],
            name: "Company 1",
            logoImg: nil,
            headerImg: nil,
            aboutUs: "",
            dateFounded: "",
            portfolioImages: [],
            address: "",
            city: "",
            phoneNum: "",
            email: "",
            workHours: "",
            services: [],
            socialMedias: nil,
            businessModel: .online,
            website: "",
            ownershipTypes: []
        )
        
        let company2 = Company(
            companyId: "same-id",
            entrepId: "entrep2", // Different entrepreneur
            categoryIds: ["cat1"], // Different categories
            name: "Company 2", // Different name
            logoImg: nil,
            headerImg: nil,
            aboutUs: "Different about us",
            dateFounded: "",
            portfolioImages: [],
            address: "",
            city: "",
            phoneNum: "",
            email: "",
            workHours: "",
            services: [],
            socialMedias: nil,
            businessModel: .online,
            website: "",
            ownershipTypes: []
        )
        
        // Companies should be equal because they have the same ID
        #expect(company1 == company2)
        
        // Create a company with a different ID
        let company3 = Company(
            companyId: "different-id",
            entrepId: "entrep1",
            categoryIds: [],
            name: "Company 1",
            logoImg: nil,
            headerImg: nil,
            aboutUs: "",
            dateFounded: "",
            portfolioImages: [],
            address: "",
            city: "",
            phoneNum: "",
            email: "",
            workHours: "",
            services: [],
            socialMedias: nil,
            businessModel: .online,
            website: "",
            ownershipTypes: []
        )
        
        // Companies should not be equal because they have different IDs
        #expect(company1 != company3)
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
