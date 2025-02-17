//
//  CategoryViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

final class AddCompanyViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    
    init() {
        Task {
            do {
                try await loadCategories()
            } catch {
                // TODO handle error
                print("Failed to load categories: \(error)")
            }
        }
    }
    
    func createCompany(company: Company) async throws {
        try await RealCompanyManager.shared.createCompany(company: company)
        try await EntrepreneurManager.shared.addCompany(company: company)
    }
    
    func saveCompany(
        entrepreneur: Entrepreneur,
        companyName: String,
        logoImage: UIImage?,
        portfolioImages: [UIImage],
        aboutUs: String,
        dateFounded: Date,
        workHours: String,
        services: String,
        businessModel: Company.BusinessModel,
        address: String,
        city: String,
        phoneNum: String,
        email: String,
        website: String,
        socialMediaInsta: String,
        socialMediaFacebook: String,
        selectedCategoryIds: Set<String>,
        selectedOwnershipTypes: Set<Company.OwnershipType>
    ) async throws {
        
        guard !selectedCategoryIds.isEmpty else {
            throw NSError(domain: "AddCompanyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No categories selected"])
        }
        
        let logoUrlString: String?
        if let logoImage = logoImage {
            logoUrlString = try await RealCompanyManager.shared.uploadLogoImage(logoImage)
        } else {
            logoUrlString = nil
        }
        
        let portfolioUrls = try await RealCompanyManager.shared.uploadPortfolioImages(portfolioImages)
        
        let newCompany = Company(
            companyId: "",
            entrepId: entrepreneur.entrepId,
            categoryIds: Array(selectedCategoryIds),
            name: companyName,
            logoImg: logoUrlString,
            aboutUs: aboutUs,
            dateFounded: formatDate(dateFounded),
            portfolioImages: portfolioUrls,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            workHours: workHours,
            services: services.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            socialMediaFacebook: socialMediaFacebook,
            socialMediaInsta: socialMediaInsta,
            businessModel: Company.BusinessModel(rawValue: businessModel.rawValue) ?? .offline,
            website: website,
            ownershipTypes: Array(selectedOwnershipTypes),
            isBookmarked: false
        )
        
        try await createCompany(company: newCompany)
    }
    
    func updateCompany(
        company: Company,
        companyName: String,
        logoImage: UIImage?,
        portfolioImages: [UIImage],
        aboutUs: String,
        dateFounded: Date,
        workHours: String,
        services: String,
        businessModel: Company.BusinessModel,
        address: String,
        city: String,
        phoneNum: String,
        email: String,
        website: String,
        socialMediaInsta: String,
        socialMediaFacebook: String,
        selectedCategoryIds: Set<String>,
        selectedOwnershipTypes: Set<Company.OwnershipType>
    ) async throws {
        guard !selectedCategoryIds.isEmpty else {
            throw NSError(domain: "AddCompanyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No categories selected"])
        }
        
        let logoUrlString: String?
        if let logoImage = logoImage {
            logoUrlString = try await RealCompanyManager.shared.uploadLogoImage(logoImage)
        } else {
            logoUrlString = company.logoImg // Keep existing logo if no new one provided
        }
        
        let portfolioUrls = try await RealCompanyManager.shared.uploadPortfolioImages(portfolioImages)
        let allPortfolioUrls = company.portfolioImages + portfolioUrls // Combine existing and new images
        
        let updatedCompany = Company(
            companyId: company.companyId,
            entrepId: company.entrepId,
            categoryIds: Array(selectedCategoryIds),
            name: companyName,
            logoImg: logoUrlString,
            aboutUs: aboutUs,
            dateFounded: formatDate(dateFounded),
            portfolioImages: allPortfolioUrls,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            workHours: workHours,
            services: services.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            socialMediaFacebook: socialMediaFacebook,
            socialMediaInsta: socialMediaInsta,
            businessModel: businessModel,
            website: website,
            ownershipTypes: Array(selectedOwnershipTypes),
            isBookmarked: company.isBookmarked
        )
        
        try await RealCompanyManager.shared.updateCompany(company: updatedCompany)
    }
    
    private func loadCategories() async throws {
        self.categories = try await CategoryManager.shared.getCategories()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
