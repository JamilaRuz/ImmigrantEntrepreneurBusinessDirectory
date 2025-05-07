//
//  CompaniesListViewModelTests.swift
//  WomenBusinessDirectoryTests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import Testing
@testable import WomenBusinessDirectory

// Mock implementation of FilterManaging for testing
class MockFilterManager: FilterManaging {
    private var selectedCities: [String] = []
    private var selectedOwnershipTypes: [Company.OwnershipType] = []
    
    func getSelectedCities() -> [String] {
        return selectedCities
    }
    
    func getSelectedOwnershipTypes() -> [Company.OwnershipType] {
        return selectedOwnershipTypes
    }
    
    func setSelectedCities(_ cities: [String]) {
        selectedCities = cities
    }
    
    func setSelectedOwnershipTypes(_ types: [Company.OwnershipType]) {
        selectedOwnershipTypes = types
    }
    
    func standardizeCity(_ city: String) -> String {
        // Simple standardization for testing
        return city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CompaniesListViewModelTests {
    
    // Helper function to create test companies
    func createTestCompanies() -> [Company] {
        return [
            Company(
                companyId: "1",
                entrepId: "e1",
                categoryIds: ["cat1", "cat2"],
                name: "Tech Company",
                logoImg: nil,
                headerImg: nil,
                aboutUs: "Software development services",
                dateFounded: "2020-01-01",
                portfolioImages: [],
                address: "123 Main St",
                city: "New York",
                phoneNum: "123-456-7890",
                email: "info@tech.com",
                workHours: "9-5",
                services: ["Software Development", "Web Design"],
                socialMedia: nil,
                businessModel: .online,
                website: "tech.com",
                ownershipTypes: [.femaleOwned, .lgbtqOwned]
            ),
            Company(
                companyId: "2",
                entrepId: "e2",
                categoryIds: ["cat2"],
                name: "Green Energy Solutions",
                logoImg: nil,
                headerImg: nil,
                aboutUs: "Renewable energy consulting",
                dateFounded: "2018-05-15",
                portfolioImages: [],
                address: "456 Park Ave",
                city: "Boston",
                phoneNum: "987-654-3210",
                email: "contact@green.com",
                workHours: "8-6",
                services: ["Energy Consulting", "Solar Installation"],
                socialMedia: nil,
                businessModel: .hybrid,
                website: "green.com",
                ownershipTypes: [.asianOwned]
            ),
            Company(
                companyId: "3",
                entrepId: "e3",
                categoryIds: ["cat1", "cat3"],
                name: "Local Cafe",
                logoImg: nil,
                headerImg: nil,
                aboutUs: "Cozy cafe with great coffee",
                dateFounded: "2019-03-10",
                portfolioImages: [],
                address: "789 Oak St",
                city: "New York",
                phoneNum: "555-123-4567",
                email: "hello@localcafe.com",
                workHours: "7-7",
                services: ["Coffee", "Pastries"],
                socialMedia: nil,
                businessModel: .offline,
                website: "localcafe.com",
                ownershipTypes: [.latinxOwned]
            )
        ]
    }
    
    @Test
    func testSearchFiltering() {
        // Create test category and filter manager
        let category = Category(id: "cat1", name: "Technology", systemIconName: "laptopcomputer")
        let filterManager = MockFilterManager()
        
        // Create test viewModel with our mocked data
        let viewModel = CompaniesListViewModel(category: category, filterManager: filterManager)
        
        // Set companies directly (in production this would come from Firebase)
        // Use reflection to set the private property
        let mirror = Mirror(reflecting: viewModel)
        if let companiesProperty = mirror.children.first(where: { $0.label == "companies" }) {
            if let companiesPropertyAddress = withUnsafePointer(to: companiesProperty.value, { $0 }) {
                let bindableCompanies = companiesPropertyAddress.withMemoryRebound(to: Published<[Company]>.self, capacity: 1) { $0 }
                if let companiesSetter = bindableCompanies.pointee.projectedValue.setter {
                    companiesSetter(createTestCompanies())
                }
            }
        }
        
        // Test with empty search term (should return all companies in category)
        viewModel.searchTerm = ""
        #expect(viewModel.filteredCompanies.count == 2) // Only companies in cat1
        
        // Test search by name
        viewModel.searchTerm = "Tech"
        #expect(viewModel.filteredCompanies.count == 1)
        #expect(viewModel.filteredCompanies.first?.name == "Tech Company")
        
        // Test search by about text
        viewModel.searchTerm = "software"
        #expect(viewModel.filteredCompanies.count == 1)
        #expect(viewModel.filteredCompanies.first?.name == "Tech Company")
        
        // Test search with no matches
        viewModel.searchTerm = "nonexistent"
        #expect(viewModel.filteredCompanies.isEmpty)
    }
    
    @Test
    func testCityFiltering() {
        // Create test category and filter manager
        let category = Category(id: "cat1", name: "Technology", systemIconName: "laptopcomputer")
        let filterManager = MockFilterManager()
        
        // Create test viewModel with our mocked data
        let viewModel = CompaniesListViewModel(category: category, filterManager: filterManager)
        
        // Set companies directly (in production this would come from Firebase)
        // Same reflection approach as before
        let mirror = Mirror(reflecting: viewModel)
        if let companiesProperty = mirror.children.first(where: { $0.label == "companies" }) {
            if let companiesPropertyAddress = withUnsafePointer(to: companiesProperty.value, { $0 }) {
                let bindableCompanies = companiesPropertyAddress.withMemoryRebound(to: Published<[Company]>.self, capacity: 1) { $0 }
                if let companiesSetter = bindableCompanies.pointee.projectedValue.setter {
                    companiesSetter(createTestCompanies())
                }
            }
        }
        
        // No city filter initially
        #expect(viewModel.filteredCompanies.count == 2) // Only companies in cat1
        
        // Filter for New York companies
        filterManager.setSelectedCities(["New York"])
        #expect(viewModel.filteredCompanies.count == 2) // Both companies in cat1 are in New York
        
        // Filter for Boston companies (should filter out all cat1 companies)
        filterManager.setSelectedCities(["Boston"])
        #expect(viewModel.filteredCompanies.isEmpty)
        
        // Test multiple cities
        filterManager.setSelectedCities(["Boston", "New York"])
        #expect(viewModel.filteredCompanies.count == 2)
        
        // Test with mixed case and extra spaces
        filterManager.setSelectedCities(["  new york  ", "BOSTON"])
        #expect(viewModel.filteredCompanies.count == 2)
    }
    
    @Test
    func testOwnershipTypeFiltering() {
        // Create test category and filter manager
        let category = Category(id: "cat1", name: "Technology", systemIconName: "laptopcomputer")
        let filterManager = MockFilterManager()
        
        // Create test viewModel with our mocked data
        let viewModel = CompaniesListViewModel(category: category, filterManager: filterManager)
        
        // Set companies directly (in production this would come from Firebase)
        // Same reflection approach as before
        let mirror = Mirror(reflecting: viewModel)
        if let companiesProperty = mirror.children.first(where: { $0.label == "companies" }) {
            if let companiesPropertyAddress = withUnsafePointer(to: companiesProperty.value, { $0 }) {
                let bindableCompanies = companiesPropertyAddress.withMemoryRebound(to: Published<[Company]>.self, capacity: 1) { $0 }
                if let companiesSetter = bindableCompanies.pointee.projectedValue.setter {
                    companiesSetter(createTestCompanies())
                }
            }
        }
        
        // No ownership filter initially
        #expect(viewModel.filteredCompanies.count == 2) // Only companies in cat1
        
        // Filter for female-owned businesses
        filterManager.setSelectedOwnershipTypes([.femaleOwned])
        #expect(viewModel.filteredCompanies.count == 1)
        #expect(viewModel.filteredCompanies.first?.name == "Tech Company")
        
        // Filter for latinx-owned businesses
        filterManager.setSelectedOwnershipTypes([.latinxOwned])
        #expect(viewModel.filteredCompanies.count == 1)
        #expect(viewModel.filteredCompanies.first?.name == "Local Cafe")
        
        // Filter for multiple ownership types
        filterManager.setSelectedOwnershipTypes([.femaleOwned, .lgbtqOwned])
        #expect(viewModel.filteredCompanies.count == 1)
        
        // Filter for ownership type not in this category
        filterManager.setSelectedOwnershipTypes([.asianOwned])
        #expect(viewModel.filteredCompanies.isEmpty)
    }
    
    @Test
    func testCombinedFiltering() {
        // Create test category and filter manager
        let category = Category(id: "cat1", name: "Technology", systemIconName: "laptopcomputer")
        let filterManager = MockFilterManager()
        
        // Create test viewModel with our mocked data
        let viewModel = CompaniesListViewModel(category: category, filterManager: filterManager)
        
        // Set companies directly (in production this would come from Firebase)
        // Same reflection approach as before
        let mirror = Mirror(reflecting: viewModel)
        if let companiesProperty = mirror.children.first(where: { $0.label == "companies" }) {
            if let companiesPropertyAddress = withUnsafePointer(to: companiesProperty.value, { $0 }) {
                let bindableCompanies = companiesPropertyAddress.withMemoryRebound(to: Published<[Company]>.self, capacity: 1) { $0 }
                if let companiesSetter = bindableCompanies.pointee.projectedValue.setter {
                    companiesSetter(createTestCompanies())
                }
            }
        }
        
        // Combine search and city filter
        viewModel.searchTerm = "coffee"
        filterManager.setSelectedCities(["New York"])
        #expect(viewModel.filteredCompanies.count == 1)
        #expect(viewModel.filteredCompanies.first?.name == "Local Cafe")
        
        // Combine search, city, and ownership filters to get zero results
        viewModel.searchTerm = "coffee"
        filterManager.setSelectedCities(["New York"])
        filterManager.setSelectedOwnershipTypes([.femaleOwned])
        #expect(viewModel.filteredCompanies.isEmpty)
        
        // Reset and use broader search with multiple filters
        viewModel.searchTerm = ""
        filterManager.setSelectedCities(["New York"])
        filterManager.setSelectedOwnershipTypes([.latinxOwned, .femaleOwned])
        #expect(viewModel.filteredCompanies.count == 2)
    }
} 