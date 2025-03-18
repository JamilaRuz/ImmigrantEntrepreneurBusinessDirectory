//
//  FilterViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 12/29/24.
//

import Foundation

@MainActor
class FilterViewModel: ObservableObject {
    @Published var cities: [String] = []
    @Published var ownershipTypes: [Company.OwnershipType] = []
    @Published var isLoading = true
    @Published var selectedCities: Set<String> = []
    @Published var selectedOwnershipTypes: Set<Company.OwnershipType> = []
    
    private let filterManager: FilterManaging
    
    init(filterManager: FilterManaging = FilterManager.shared) {
        self.filterManager = filterManager
        self.selectedCities = filterManager.getSelectedCities()
        self.selectedOwnershipTypes = filterManager.getSelectedOwnershipTypes()
        Task {
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
        } catch {
            print("Error fetching filter options: \(error)")
            isLoading = false
        }
    }
    
    func toggleCity(_ city: String) {
        // Get the standardized version of the city name
        let standardizedCity = filterManager.standardizeCity(city)
        
        // Check if any version of this city is already selected
        let alreadySelected = selectedCities.contains { 
            filterManager.standardizeCity($0) == standardizedCity
        }
        
        if alreadySelected {
            // Remove any versions of this city that match the standardized name
            selectedCities = selectedCities.filter { 
                filterManager.standardizeCity($0) != standardizedCity
            }
        } else {
            // Add the standardized city name
            selectedCities.insert(standardizedCity)
        }
        
        filterManager.saveSelectedCities(selectedCities)
    }
    
    func toggleOwnershipType(_ type: Company.OwnershipType) {
        if selectedOwnershipTypes.contains(type) {
            selectedOwnershipTypes.remove(type)
        } else {
            selectedOwnershipTypes.insert(type)
        }
        filterManager.saveSelectedOwnershipTypes(selectedOwnershipTypes)
    }
    
    func clearFilters() {
        selectedCities.removeAll()
        selectedOwnershipTypes.removeAll()
        filterManager.clearAllFilters()
    }
}

