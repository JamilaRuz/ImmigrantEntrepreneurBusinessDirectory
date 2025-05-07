//
//  CategoryManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

struct Category: Codable, Hashable {
    let id: String
    let name: String
    let systemIconName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case systemIconName
    }
    
    init(id: String, name: String, systemIconName: String) {
        self.id = id
        self.name = name
        self.systemIconName = systemIconName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.systemIconName = try container.decode(String.self, forKey: .systemIconName)
        // If id is in the data use it, otherwise it will be set from documentID
        self.id = (try? container.decode(String.self, forKey: .id)) ?? ""
    }
}

@MainActor
class CategoryManager {
    static let shared = CategoryManager()
    private init() {}
    
    private let categoriesCollection = Firestore.firestore().collection("categories")
    private let companiesCollection = Firestore.firestore().collection("companies")
    
    func getCategories() async throws -> [Category] {
        let snapshot = try await categoriesCollection.getDocuments()
        return try snapshot.documents.compactMap { document in
            let decodedCategory = try document.data(as: Category.self)
            return decodedCategory.id.isEmpty ? 
                Category(id: document.documentID, name: decodedCategory.name, systemIconName: decodedCategory.systemIconName) : 
                decodedCategory
        }.sorted { $0.name < $1.name }
    }
    
    func getCategoriesWithCompanyCount(
        selectedCity: String?,
    ) async throws -> [(category: Category, count: Int)] {
        // Get all categories and companies in parallel
        async let categoriesTask = getCategories()
        async let companiesSnapshot = companiesCollection.getDocuments()
        
        // Wait for both to complete
        let (categories, snapshot) = try await (categoriesTask, companiesSnapshot)
        
        // Convert company documents to array of company data with required fields
        let companyData = try snapshot.documents.compactMap { document -> (categoryIds: [String], city: String) in
            // Decode the full company to ensure data integrity
            let company = try document.data(as: Company.self)
            return (categoryIds: company.categoryIds, city: company.city)
        }
        
        // Count companies for each category with filters
        return categories.map { category in
            let count = companyData.filter { companyInfo in
                // First check if company belongs to this category
                guard companyInfo.categoryIds.contains(category.id) else { return false }
                
                // Apply city filter if selected
                if let selectedCity = selectedCity, 
                   !selectedCity.isEmpty,
                   companyInfo.city != selectedCity {
                    return false
                }
                
                return true
            }.count
            
            return (category: category, count: count)
        }
    }
    
    func filterCompaniesByCategory(
        companies: [Company],
        selectedCategoryIds: Set<String>,
        selectedCities: Set<String>
    ) -> [Company] {
        // If no categories are selected, return all companies
        if selectedCategoryIds.isEmpty && selectedCities.isEmpty {
            return companies
        }
        
        return companies.filter { company in
            // Category filter: if selectedCategoryIds is not empty, 
            // check if company has any of the selected categories
            let passesCategory = selectedCategoryIds.isEmpty ||
                !Set(company.categoryIds).isDisjoint(with: selectedCategoryIds)
            
            // City filter: if selectedCities is not empty, 
            // check if company's city is one of the selected cities
            let passesCity = selectedCities.isEmpty ||
                selectedCities.contains(company.city)
            
            return passesCategory && passesCity
        }
    }
}
