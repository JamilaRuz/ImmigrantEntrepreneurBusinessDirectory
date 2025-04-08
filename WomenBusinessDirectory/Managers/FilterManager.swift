//
//  FilterManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 12/29/24.
//

import Foundation
import FirebaseFirestore

protocol FilterManaging {
    // Add nonisolated to methods that don't need MainActor isolation
    nonisolated func getSelectedCities() -> Set<String>
    nonisolated func getSelectedOwnershipTypes() -> Set<Company.OwnershipType>
    func saveSelectedCities(_ cities: Set<String>)
    func saveSelectedOwnershipTypes(_ types: Set<Company.OwnershipType>)
    func clearAllFilters()
    func fetchCities() async throws -> [String]
    nonisolated func fetchOwnershipTypes() -> [Company.OwnershipType]
    nonisolated func applyFilters(to companies: [Company]) -> [Company]
    func clearCache() async
    nonisolated func standardizeCity(_ city: String) -> String
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
    
    // MARK: - Helper Methods
    
    nonisolated func standardizeCity(_ city: String) -> String {
        // Remove any commas and everything that follows
        // This way "Ottawa", "Ottawa, ON", and "Ottawa, Ontario" will all become just "Ottawa"
        if let commaRange = city.range(of: ",") {
            return String(city[..<commaRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return city.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Filter State Management
    
    nonisolated func getSelectedCities() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: selectedCitiesKey) ?? []
        return Set(array)
    }
    
    nonisolated func getSelectedOwnershipTypes() -> Set<Company.OwnershipType> {
        let rawValues = UserDefaults.standard.stringArray(forKey: selectedOwnershipTypesKey) ?? []
        return Set(rawValues.compactMap { Company.OwnershipType(rawValue: $0) })
    }
    
    nonisolated func saveSelectedCities(_ cities: Set<String>) {
        UserDefaults.standard.set(Array(cities), forKey: selectedCitiesKey)
    }
    
    nonisolated func saveSelectedOwnershipTypes(_ types: Set<Company.OwnershipType>) {
        let rawValues = types.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: selectedOwnershipTypesKey)
    }
    
    nonisolated func clearAllFilters() {
        UserDefaults.standard.removeObject(forKey: selectedCitiesKey)
        UserDefaults.standard.removeObject(forKey: selectedOwnershipTypesKey)
    }
    
    // MARK: - Available Options Fetching
    
    func fetchCities() async throws -> [String] {
        if let cached = availableCitiesCache {
            print("Debug - Using cached cities: \(cached)")
            return cached
        }
        
        // Fetch unique cities from all companies
        let snapshot = try await Firestore.firestore()
            .collection("companies")
            .getDocuments()
        
        print("Debug - Firestore documents count: \(snapshot.documents.count)")
        
        let cities = snapshot.documents
            .compactMap { document -> String? in
                let data = document.data()
                let city = data["city"] as? String
                print("Debug - Found city in document \(document.documentID): \(city ?? "nil")")
                return city
            }
            .filter { !$0.isEmpty } // Filter out empty strings
        
        print("Debug - All cities before deduplication: \(cities)")
        
        // Standardize city names before deduplication
        let standardizedCities = cities.map(standardizeCity)
        
        print("Debug - Cities after standardization: \(standardizedCities)")
        
        // Remove duplicates and sort
        let uniqueCities = Array(Set(standardizedCities)).sorted()
        print("Debug - Unique cities after deduplication: \(uniqueCities)")
        
        availableCitiesCache = uniqueCities
        return uniqueCities
    }
    
    nonisolated func fetchOwnershipTypes() -> [Company.OwnershipType] {
        return Company.OwnershipType.allCases
    }
    
    // MARK: - Filter Application
    
    nonisolated func applyFilters(to companies: [Company]) -> [Company] {
        let selectedCitiesRaw = getSelectedCities()
        let selectedTypes = getSelectedOwnershipTypes()
        
        // Standardize the selected cities the same way we do for the displayed cities
        let standardizedSelectedCities = Set(selectedCitiesRaw.map(standardizeCity))
        print("Debug - Standardized selected cities: \(standardizedSelectedCities)")
        
        var filtered = companies
        
        // Apply city filter if cities are selected
        if !standardizedSelectedCities.isEmpty {
            filtered = filtered.filter { company in
                // Standardize company city name
                let standardizedCity = standardizeCity(company.city)
                print("Debug - Checking if \(standardizedCity) is in \(standardizedSelectedCities)")
                return standardizedSelectedCities.contains(standardizedCity)
            }
        }
        
        // Apply ownership type filter if types are selected
        if !selectedTypes.isEmpty {
            filtered = filtered.filter { company in
                !selectedTypes.isDisjoint(with: Set(company.ownershipTypes))
            }
        }
        
        return filtered
    }
    
    // MARK: - Cache Management
    
    func clearCache() async {
        availableCitiesCache = nil
    }
}

