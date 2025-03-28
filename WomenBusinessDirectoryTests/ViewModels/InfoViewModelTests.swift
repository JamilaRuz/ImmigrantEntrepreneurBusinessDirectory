//
//  InfoViewModelTests.swift
//  WomenBusinessDirectoryTests
//
//  Created by Jamila Ruzimetova on 3/1/25.
//

import Testing
@testable import WomenBusinessDirectory

// Mock EntrepreneurManager for testing InfoViewModel
class MockEntrepreneurManagerForInfoView {
    var entrepreneurs: [String: Entrepreneur] = [:]
    var shouldFail = false
    var loadDelay: TimeInterval = 0
    
    init() {
        // Pre-populate with test data
        entrepreneurs["valid-id"] = Entrepreneur(
            entrepId: "valid-id",
            fullName: "Jane Doe",
            profileUrl: "profile.jpg",
            email: "jane@example.com",
            bioDescr: "Entrepreneur bio",
            companyIds: ["company-1", "company-2"]
        )
    }
    
    func getEntrepreneur(entrepId: String) async throws -> Entrepreneur {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        if loadDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(loadDelay * 1_000_000_000))
        }
        
        guard let entrepreneur = entrepreneurs[entrepId] else {
            throw NSError(domain: "NotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Entrepreneur not found"])
        }
        
        return entrepreneur
    }
}

// Extend InfoViewModel to allow injecting our mock
extension InfoViewModel {
    convenience init(mockManager: MockEntrepreneurManagerForInfoView) {
        self.init()
        self.mockManager = mockManager
    }
    
    // Use a backing variable to store our mock
    private var mockManager: MockEntrepreneurManagerForInfoView?
    
    // Override the loadEntrepreneur method to use our mock
    @MainActor
    func mockLoadEntrepreneur(entrepId: String) async {
        isLoading = true
        error = nil
        
        do {
            if let mockManager = mockManager {
                self.entrepreneur = try await mockManager.getEntrepreneur(entrepId: entrepId)
            } else {
                self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: entrepId)
            }
        } catch {
            print("Failed to load entrepreneur: \(error)")
            self.error = "Failed to load entrepreneur information. Please try again later."
        }
        
        isLoading = false
    }
}

struct InfoViewModelTests {
    
    @Test
    func testSuccessfulEntrepreneurLoad() async {
        // Create mock manager
        let mockManager = MockEntrepreneurManagerForInfoView()
        
        // Create viewModel with mock
        let viewModel = InfoViewModel(mockManager: mockManager)
        
        // Call the mock load function
        await viewModel.mockLoadEntrepreneur(entrepId: "valid-id")
        
        // Verify the entrepreneur was loaded correctly
        #expect(viewModel.entrepreneur.entrepId == "valid-id")
        #expect(viewModel.entrepreneur.fullName == "Jane Doe")
        #expect(viewModel.entrepreneur.email == "jane@example.com")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test
    func testFailedEntrepreneurLoad() async {
        // Create mock manager set to fail
        let mockManager = MockEntrepreneurManagerForInfoView()
        mockManager.shouldFail = true
        
        // Create viewModel with mock
        let viewModel = InfoViewModel(mockManager: mockManager)
        
        // Call the mock load function
        await viewModel.mockLoadEntrepreneur(entrepId: "valid-id")
        
        // Verify error state
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
        #expect(viewModel.entrepreneur.fullName?.isEmpty != false)
    }
    
    @Test
    func testEntrepreneurNotFound() async {
        // Create mock manager
        let mockManager = MockEntrepreneurManagerForInfoView()
        
        // Create viewModel with mock
        let viewModel = InfoViewModel(mockManager: mockManager)
        
        // Call the mock load function with non-existent ID
        await viewModel.mockLoadEntrepreneur(entrepId: "non-existent-id")
        
        // Verify error state
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
        #expect(viewModel.entrepreneur.fullName?.isEmpty != false)
    }
    
    @Test
    func testLoadingState() async {
        // Create mock manager with delay
        let mockManager = MockEntrepreneurManagerForInfoView()
        mockManager.loadDelay = 0.1 // 100ms delay
        
        // Create viewModel with mock
        let viewModel = InfoViewModel(mockManager: mockManager)
        
        // Start loading in background
        Task {
            await viewModel.mockLoadEntrepreneur(entrepId: "valid-id")
        }
        
        // Immediately check loading state
        #expect(viewModel.isLoading == true)
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Check final state
        #expect(viewModel.isLoading == false)
        #expect(viewModel.entrepreneur.fullName == "Jane Doe")
    }
} 