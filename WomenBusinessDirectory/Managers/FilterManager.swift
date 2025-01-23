//
//  FilterManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 12/29/24.
//

import Foundation
import FirebaseFirestore

protocol FilterManaging {
    func getSelectedCities() -> Set<String>
    func getSelectedOwnershipTypes() -> Set<Company.OwnershipType>
    func saveSelectedCities(_ cities: Set<String>)
    func saveSelectedOwnershipTypes(_ types: Set<Company.OwnershipType>)
    func clearAllFilters()
    func fetchCities() async throws -> [String]
    func fetchOwnershipTypes() -> [Company.OwnershipType]
    func applyFilters(to companies: [Company]) -> [Company]
    func clearCache()
}

@MainActor
class FilterManager: FilterManaging {
    // Shared instance for convenience, but not required
    static let shared = FilterManager()
    
    // Make init public to allow creating new instances if needed
    init() {}
    
    // UserDefaults keys
    private let selectedCitiesKey = "selectedCities"
    private let selectedOwnershipTypesKey = "selectedOwnershipTypes"
    
    // Cache for available options
    private var availableCitiesCache: [String]?
    
    // MARK: - Filter State Management
    
    func getSelectedCities() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: selectedCitiesKey) ?? []
        return Set(array)
    }
    
    func getSelectedOwnershipTypes() -> Set<Company.OwnershipType> {
        let rawValues = UserDefaults.standard.stringArray(forKey: selectedOwnershipTypesKey) ?? []
        return Set(rawValues.compactMap { Company.OwnershipType(rawValue: $0) })
    }
    
    func saveSelectedCities(_ cities: Set<String>) {
        UserDefaults.standard.set(Array(cities), forKey: selectedCitiesKey)
    }
    
    func saveSelectedOwnershipTypes(_ types: Set<Company.OwnershipType>) {
        let rawValues = types.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: selectedOwnershipTypesKey)
    }
    
    func clearAllFilters() {
        UserDefaults.standard.removeObject(forKey: selectedCitiesKey)
        UserDefaults.standard.removeObject(forKey: selectedOwnershipTypesKey)
    }
    
    // MARK: - Available Options Fetching
    
    func fetchCities() async throws -> [String] {
        if let cached = availableCitiesCache {
            return cached
        }
        
        // Fetch unique cities from all companies
        let snapshot = try await Firestore.firestore()
            .collection("companies")
            .getDocuments()
        
        let cities = snapshot.documents
            .compactMap { document -> String? in
                let data = document.data()
                return data["city"] as? String
            }
        
        // Remove duplicates and sort
        let uniqueCities = Array(Set(cities)).sorted()
        availableCitiesCache = uniqueCities
        return uniqueCities
    }
    
    func fetchOwnershipTypes() -> [Company.OwnershipType] {
        return Company.OwnershipType.allCases
    }
    
    // MARK: - Filter Application
    
    func applyFilters(to companies: [Company]) -> [Company] {
        let selectedCities = getSelectedCities()
        let selectedTypes = getSelectedOwnershipTypes()
        
        var filtered = companies
        
        // Apply city filter if cities are selected
        if !selectedCities.isEmpty {
            filtered = filtered.filter { company in
                selectedCities.contains(company.city)
            }
        }
        
        // Apply ownership type filter if types are selected
        if !selectedTypes.isEmpty {
            filtered = filtered.filter { company in
                !selectedTypes.isDisjoint(with: Set(company.ownershipTypes ?? []))
            }
        }
        
        return filtered
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        availableCitiesCache = nil
    }
}

