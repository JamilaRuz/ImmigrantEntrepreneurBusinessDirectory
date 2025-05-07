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
    nonisolated func getSelectedCountries() -> Set<String>
    func saveSelectedCities(_ cities: Set<String>)
    func saveSelectedCountries(_ countries: Set<String>)
    func clearAllFilters()
    func fetchCities() async throws -> [String]
    func fetchCountries() async throws -> [String]
    func setAvailableCountries(_ countries: [String]) async throws
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
    private let selectedCountriesKey = "selectedCountries"
    
    // Cache for available options
    private var availableCitiesCache: [String]?
    private var availableCountriesCache: [String]?
    
    // Dictionary to map amalgamated cities to their parent cities
    private let amalgamatedCitiesMap: [String: String] = [
        // Ottawa amalgamations
        "nepean": "Ottawa",
        "kanata": "Ottawa",
        "orleans": "Ottawa",
        "gloucester": "Ottawa",
        "cumberland": "Ottawa",
        "vanier": "Ottawa",
        "rockcliffe park": "Ottawa",
        "osgoode": "Ottawa",
        "rideau": "Ottawa",
        "goulbourn": "Ottawa",
        
        // Toronto amalgamations
        "etobicoke": "Toronto",
        "scarborough": "Toronto",
        "north york": "Toronto",
        "east york": "Toronto",
        "york": "Toronto",
        
        // Montreal amalgamations
        "anjou": "Montreal",
        "lachine": "Montreal",
        "lasalle": "Montreal",
        "outremont": "Montreal",
        "pierrefonds-roxboro": "Montreal",
        "pierrefonds": "Montreal",
        "roxboro": "Montreal",
        "saint-laurent": "Montreal",
        "st-laurent": "Montreal",
        "verdun": "Montreal",
        "ville-marie": "Montreal",
        
        // Quebec City amalgamations
        "beauport": "Quebec City",
        "charlesbourg": "Quebec City",
        "sainte-foy": "Quebec City",
        "ste-foy": "Quebec City",
        "sillery": "Quebec City",
        "vanier, qc": "Quebec City"
    ]
    
    // MARK: - Helper Methods
    
    nonisolated func standardizeCity(_ city: String) -> String {
        // First remove any commas and everything that follows
        let cityName: String
        if let commaRange = city.range(of: ",") {
            cityName = String(city[..<commaRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            cityName = city.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Convert to lowercase for case-insensitive comparison
        let lowercasedCity = cityName.lowercased()
        
        // Check if this is an amalgamated city and should be standardized to its parent city
        if let parentCity = amalgamatedCitiesMap[lowercasedCity] {
            print("Standardizing amalgamated city: \(cityName) -> \(parentCity)")
            return parentCity
        }
        
        // Return the original city name with proper capitalization
        return cityName
    }
    
    // MARK: - Filter State Management
    
    nonisolated func getSelectedCities() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: selectedCitiesKey) ?? []
        return Set(array)
    }
    
    nonisolated func getSelectedCountries() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: selectedCountriesKey) ?? []
        return Set(array)
    }
    
    nonisolated func saveSelectedCities(_ cities: Set<String>) {
        UserDefaults.standard.set(Array(cities), forKey: selectedCitiesKey)
    }
    
    nonisolated func saveSelectedCountries(_ countries: Set<String>) {
        UserDefaults.standard.set(Array(countries), forKey: selectedCountriesKey)
    }
    
    nonisolated func clearAllFilters() {
        UserDefaults.standard.removeObject(forKey: selectedCitiesKey)
        UserDefaults.standard.removeObject(forKey: selectedCountriesKey)
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
    
    func fetchCountries() async throws -> [String] {
        if let cached = availableCountriesCache {
            print("Debug - Using cached countries: \(cached)")
            return cached
        }
        
        // Fetch unique countries from all entrepreneurs
        let snapshot = try await Firestore.firestore()
            .collection("entrepreneurs")
            .getDocuments()
        
        print("Debug - Firestore entrepreneurs count: \(snapshot.documents.count)")
        
        let countries = snapshot.documents
            .compactMap { document -> String? in
                let data = document.data()
                let country = data["countryOfOrigin"] as? String
                print("Debug - Found country in document \(document.documentID): \(country ?? "nil")")
                return country
            }
            .filter { !$0.isEmpty } // Filter out empty strings
        
        print("Debug - All countries before deduplication: \(countries)")
        
        // Remove duplicates and sort
        let uniqueCountries = Array(Set(countries)).sorted()
        print("Debug - Unique countries after deduplication: \(uniqueCountries)")
        
        availableCountriesCache = uniqueCountries
        return uniqueCountries
    }
    
    // MARK: - Filter Application
    
    nonisolated func applyFilters(to companies: [Company]) -> [Company] {
        let selectedCitiesRaw = getSelectedCities()
        _ = getSelectedCountries()
        
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
        
        return filtered
    }
    
    // MARK: - Cache Management
    
    func clearCache() async {
        availableCitiesCache = nil
        availableCountriesCache = nil
    }
    
    func setAvailableCountries(_ countries: [String]) async throws {
        // Simply update the cache with the provided countries
        self.availableCountriesCache = countries
        print("FilterManager: Updated available countries: \(countries)")
    }
}

