//
//  FilterViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 12/29/24.
//

import Foundation
import SwiftUI

@MainActor
class FilterViewModel: ObservableObject {
    @Published var cities: [String] = []
    @Published var ownershipTypes: [Company.OwnershipType] = []
    @Published var isLoading = true
    @Published var selectedCities: Set<String> = []
    @Published var selectedOwnershipTypes: Set<Company.OwnershipType> = []
    
    private let filterManager: FilterManaging
    
    init(filterManager: FilterManaging? = nil) {
        // In Swift 6, we must explicitly access FilterManager.shared on the MainActor
        // Instead of using a nonisolated helper, we initialize directly within MainActor context
        if let filterManager = filterManager {
            self.filterManager = filterManager
        } else {
            // Since this class is @MainActor, and init runs on MainActor,
            // this access to FilterManager.shared is allowed
            self.filterManager = FilterManager.shared
        }
        
        // Initialize with empty sets then load properly
        self.selectedCities = []
        self.selectedOwnershipTypes = []
        
        // Load initial values
        Task {
            self.selectedCities = self.filterManager.getSelectedCities()
            self.selectedOwnershipTypes = self.filterManager.getSelectedOwnershipTypes()
            await fetchFilterOptions()
        }
    }
    
    func fetchFilterOptions() async {
        do {
            // Fetch cities asynchronously
            let fetchedCities = try await filterManager.fetchCities()
            print("Debug - Cities from Firestore: \(fetchedCities)")
            
            // Get ownership types synchronously
            let fetchedOwnershipTypes = filterManager.fetchOwnershipTypes()
            
            // Update published properties on main actor
            cities = fetchedCities
            ownershipTypes = fetchedOwnershipTypes
            isLoading = false
            
            // After loading cities, ensure selected cities are standardized
            standardizeSelectedCities()
        } catch {
            print("Error fetching filter options: \(error)")
            isLoading = false
        }
    }
    
    // New method to ensure selected cities are using standardized names
    private func standardizeSelectedCities() {
        // Create a new set with standardized names
        var standardizedSet = Set<String>()
        
        for city in selectedCities {
            let standardized = filterManager.standardizeCity(city)
            standardizedSet.insert(standardized)
        }
        
        // Replace the current selection with standardized names
        if standardizedSet != selectedCities {
            selectedCities = standardizedSet
            // Save the standardized selection
            Task {
                filterManager.saveSelectedCities(selectedCities)
            }
        }
    }
    
    func toggleCity(_ city: String) {
        // Get the standardized version of the city name
        let standardizedCity = filterManager.standardizeCity(city)
        
        // Check if this city is already selected
        if selectedCities.contains(standardizedCity) {
            selectedCities.remove(standardizedCity)
        } else {
            // Add the standardized city name
            selectedCities.insert(standardizedCity)
        }
        
        Task {
            filterManager.saveSelectedCities(selectedCities)
        }
    }
    
    func toggleOwnershipType(_ type: Company.OwnershipType) {
        if selectedOwnershipTypes.contains(type) {
            selectedOwnershipTypes.remove(type)
        } else {
            selectedOwnershipTypes.insert(type)
        }
        Task {
            filterManager.saveSelectedOwnershipTypes(selectedOwnershipTypes)
        }
    }
    
    func clearFilters() {
        selectedCities.removeAll()
        selectedOwnershipTypes.removeAll()
        Task {
            filterManager.clearAllFilters()
        }
    }
    
    // Helper to check if a city is an amalgamated smaller city
    func isAmalgamatedCity(_ city: String) -> Bool {
        // The standardized city will be different from the original
        // if it's an amalgamated city
        let standardized = filterManager.standardizeCity(city)
        return standardized != city && !standardized.isEmpty
    }
    
    // Helper to get the parent city of an amalgamated city
    func parentCityFor(_ city: String) -> String? {
        let standardized = filterManager.standardizeCity(city)
        return standardized != city ? standardized : nil
    }
}

