//
//  EntrepreneurManagerTests.swift
//  WomenBusinessDirectoryTests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import Testing
@testable import WomenBusinessDirectory

// Mock implementation of EntrepreneurManager for testing
class MockEntrepreneurManagerImpl {
    var entrepreneurs: [String: Entrepreneur] = [:]
    
    func getEntrepreneur(entrepId: String) -> Entrepreneur? {
        return entrepreneurs[entrepId]
    }
    
    func createEntrepreneur(entrepreneur: Entrepreneur) {
        entrepreneurs[entrepreneur.entrepId] = entrepreneur
    }
    
    func updateEntrepreneur(_ entrepreneur: Entrepreneur) {
        entrepreneurs[entrepreneur.entrepId] = entrepreneur
    }
    
    func addCompanyToEntrepreneur(entrepId: String, companyId: String) -> Bool {
        guard var entrepreneur = entrepreneurs[entrepId] else {
            return false
        }
        
        entrepreneur.companyIds.append(companyId)
        entrepreneurs[entrepId] = entrepreneur
        return true
    }
    
    func removeCompanyFromEntrepreneur(entrepId: String, companyId: String) -> Bool {
        guard var entrepreneur = entrepreneurs[entrepId] else {
            return false
        }
        
        entrepreneur.companyIds.removeAll { $0 == companyId }
        entrepreneurs[entrepId] = entrepreneur
        return true
    }
}

struct EntrepreneurManagerTests {
    
    @Test
    func testEntrepreneurCreation() {
        // Create a mock entrepreneur manager
        let mockManager = MockEntrepreneurManagerImpl()
        
        // Create a test entrepreneur
        let entrepreneur = Entrepreneur(
            entrepId: "test-id",
            fullName: "Test User",
            profileUrl: "profile.jpg",
            email: "test@example.com",
            bioDescr: "This is a test bio",
            companyIds: []
        )
        
        // Add to mock manager
        mockManager.createEntrepreneur(entrepreneur: entrepreneur)
        
        // Verify entrepreneur was added correctly
        let retrievedEntrepreneur = mockManager.getEntrepreneur(entrepId: "test-id")
        #expect(retrievedEntrepreneur != nil)
        #expect(retrievedEntrepreneur?.entrepId == "test-id")
        #expect(retrievedEntrepreneur?.fullName == "Test User")
        #expect(retrievedEntrepreneur?.email == "test@example.com")
        #expect(retrievedEntrepreneur?.bioDescr == "This is a test bio")
        #expect(retrievedEntrepreneur?.companyIds.isEmpty == true)
    }
    
    @Test
    func testAddCompanyToEntrepreneur() {
        // Create a mock entrepreneur manager
        let mockManager = MockEntrepreneurManagerImpl()
        
        // Create a test entrepreneur
        let entrepreneur = Entrepreneur(
            entrepId: "test-id",
            fullName: "Test User",
            profileUrl: nil,
            email: "test@example.com",
            bioDescr: "",
            companyIds: []
        )
        
        // Add to mock manager
        mockManager.createEntrepreneur(entrepreneur: entrepreneur)
        
        // Add a company to the entrepreneur
        let success = mockManager.addCompanyToEntrepreneur(entrepId: "test-id", companyId: "company-1")
        #expect(success == true)
        
        // Verify company was added correctly
        let retrievedEntrepreneur = mockManager.getEntrepreneur(entrepId: "test-id")
        #expect(retrievedEntrepreneur?.companyIds.count == 1)
        #expect(retrievedEntrepreneur?.companyIds.first == "company-1")
        
        // Add another company
        _ = mockManager.addCompanyToEntrepreneur(entrepId: "test-id", companyId: "company-2")
        
        // Verify both companies are in the list
        let updatedEntrepreneur = mockManager.getEntrepreneur(entrepId: "test-id")
        #expect(updatedEntrepreneur?.companyIds.count == 2)
        #expect(updatedEntrepreneur?.companyIds.contains("company-1") == true)
        #expect(updatedEntrepreneur?.companyIds.contains("company-2") == true)
    }
    
    @Test
    func testRemoveCompanyFromEntrepreneur() {
        // Create a mock entrepreneur manager
        let mockManager = MockEntrepreneurManagerImpl()
        
        // Create a test entrepreneur with companies
        let entrepreneur = Entrepreneur(
            entrepId: "test-id",
            fullName: "Test User",
            profileUrl: nil,
            email: "test@example.com",
            bioDescr: "",
            companyIds: ["company-1", "company-2", "company-3"]
        )
        
        // Add to mock manager
        mockManager.createEntrepreneur(entrepreneur: entrepreneur)
        
        // Remove a company
        let success = mockManager.removeCompanyFromEntrepreneur(entrepId: "test-id", companyId: "company-2")
        #expect(success == true)
        
        // Verify company was removed correctly
        let retrievedEntrepreneur = mockManager.getEntrepreneur(entrepId: "test-id")
        #expect(retrievedEntrepreneur?.companyIds.count == 2)
        #expect(retrievedEntrepreneur?.companyIds.contains("company-1") == true)
        #expect(retrievedEntrepreneur?.companyIds.contains("company-2") == false)
        #expect(retrievedEntrepreneur?.companyIds.contains("company-3") == true)
    }
    
    @Test
    func testUpdateEntrepreneur() {
        // Create a mock entrepreneur manager
        let mockManager = MockEntrepreneurManagerImpl()
        
        // Create a test entrepreneur
        let entrepreneur = Entrepreneur(
            entrepId: "test-id",
            fullName: "Test User",
            profileUrl: nil,
            email: "test@example.com",
            bioDescr: "Initial bio",
            companyIds: []
        )
        
        // Add to mock manager
        mockManager.createEntrepreneur(entrepreneur: entrepreneur)
        
        // Update the entrepreneur
        var updatedEntrepreneur = entrepreneur
        updatedEntrepreneur.fullName = "Updated Name"
        updatedEntrepreneur.bioDescr = "Updated bio"
        updatedEntrepreneur.profileUrl = "new-profile.jpg"
        
        mockManager.updateEntrepreneur(updatedEntrepreneur)
        
        // Verify entrepreneur was updated correctly
        let retrievedEntrepreneur = mockManager.getEntrepreneur(entrepId: "test-id")
        #expect(retrievedEntrepreneur?.fullName == "Updated Name")
        #expect(retrievedEntrepreneur?.bioDescr == "Updated bio")
        #expect(retrievedEntrepreneur?.profileUrl == "new-profile.jpg")
    }
    
    @Test
    func testEntrepreneurNotFound() {
        // Create a mock entrepreneur manager
        let mockManager = MockEntrepreneurManagerImpl()
        
        // Attempt to get a non-existent entrepreneur
        let retrievedEntrepreneur = mockManager.getEntrepreneur(entrepId: "non-existent-id")
        #expect(retrievedEntrepreneur == nil)
        
        // Attempt to add company to non-existent entrepreneur
        let success = mockManager.addCompanyToEntrepreneur(entrepId: "non-existent-id", companyId: "company-1")
        #expect(success == false)
    }
} 