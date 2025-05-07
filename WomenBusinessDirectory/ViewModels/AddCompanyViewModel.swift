//
//  CategoryViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import Foundation
import FirebaseFirestore
import UIKit

@MainActor
final class AddCompanyViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published var isSaving = false
    
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
    
    func createCompany(
        entrepreneur: Entrepreneur,
        companyName: String,
        logoImage: UIImage?,
        headerImage: UIImage?,
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
        socialMediaLinks: [(platform: Company.SocialMedia, link: String)],
        selectedCategoryIds: Set<String>
    ) async throws {
        isSaving = true
        defer { isSaving = false }
        
        // Convert social media links to dictionary
        var socialMediaDict: [Company.SocialMedia: String] = [:]
        for (platform, link) in socialMediaLinks where !link.isEmpty {
            socialMediaDict[platform] = link
        }
        
        // Upload images
        let logoUrlString = logoImage != nil ? try await uploadImage(logoImage!, to: "logos") : nil
        let headerUrlString = headerImage != nil ? try await uploadImage(headerImage!, to: "headers") : nil
        
        // Upload portfolio images in parallel
        let portfolioUrls = try await uploadPortfolioImages(portfolioImages)
        
        // Create company object
        let newCompany = Company(
            companyId: "",
            entrepId: entrepreneur.entrepId,
            categoryIds: Array(selectedCategoryIds),
            name: companyName,
            logoImg: logoUrlString,
            headerImg: headerUrlString,
            aboutUs: aboutUs,
            dateFounded: formatDate(dateFounded),
            portfolioImages: portfolioUrls,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            workHours: workHours,
            services: services.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            socialMedias: socialMediaDict,
            businessModel: businessModel,
            website: website,
            isBookmarked: false
        )
        
        try await RealCompanyManager.shared.createCompany(company: newCompany)
    }
    
    func saveCompany(
        entrepreneur: Entrepreneur,
        companyName: String,
        logoImage: UIImage?,
        headerImage: UIImage?,
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
        socialMediaLinks: [(platform: Company.SocialMedia, link: String)],
        selectedCategoryIds: Set<String>
    ) async throws {
        isSaving = true
        defer { isSaving = false }
        
        guard !selectedCategoryIds.isEmpty else {
            throw NSError(domain: "AddCompanyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No categories selected"])
        }
        
        let logoUrlString: String?
        if let logoImage = logoImage {
            logoUrlString = try await RealCompanyManager.shared.uploadLogoImage(logoImage)
        } else {
            logoUrlString = nil
        }
        
        let headerUrlString: String?
        if let headerImage = headerImage {
            headerUrlString = try await RealCompanyManager.shared.uploadHeaderImage(headerImage)
        } else {
            headerUrlString = nil
        }
        
        let portfolioUrls = try await RealCompanyManager.shared.uploadPortfolioImages(portfolioImages)
        
        // Convert the array of tuples to a dictionary
        var socialMediaDict: [Company.SocialMedia: String] = [:]
        for link in socialMediaLinks {
            socialMediaDict[link.platform] = link.link
        }
        
        let newCompany = Company(
            companyId: "",
            entrepId: entrepreneur.entrepId,
            categoryIds: Array(selectedCategoryIds),
            name: companyName,
            logoImg: logoUrlString,
            headerImg: headerUrlString,
            aboutUs: aboutUs,
            dateFounded: formatDate(dateFounded),
            portfolioImages: portfolioUrls,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            workHours: workHours,
            services: services.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            socialMedias: socialMediaDict,
            businessModel: Company.BusinessModel(rawValue: businessModel.rawValue) ?? .offline,
            website: website,
            isBookmarked: false
        )
        
        try await createCompany(company: newCompany)
    }
    
    func updateCompany(
        company: Company,
        companyName: String,
        logoImage: UIImage?,
        headerImage: UIImage?,
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
        socialMediaLinks: [(platform: Company.SocialMedia, link: String)],
        selectedCategoryIds: Set<String>
    ) async throws {
        guard !selectedCategoryIds.isEmpty else {
            throw NSError(domain: "AddCompanyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No categories selected"])
        }
        
        let logoUrlString: String?
        if let logoImage = logoImage {
            // Delete old logo image if it exists
            if let existingLogoUrl = company.logoImg {
                do {
                    try await RealCompanyManager.shared.deleteImageFromStorage(imageUrl: existingLogoUrl)
                    print("Successfully deleted old logo image")
                } catch {
                    print("Error deleting old logo image: \(error.localizedDescription)")
                    // Continue with the update even if deletion fails
                }
            }
            logoUrlString = try await RealCompanyManager.shared.uploadLogoImage(logoImage)
        } else {
            logoUrlString = company.logoImg // Keep existing logo if no new one provided
        }
        
        let headerUrlString: String?
        if let headerImage = headerImage {
            // Delete old header image if it exists
            if let existingHeaderUrl = company.headerImg {
                do {
                    try await RealCompanyManager.shared.deleteImageFromStorage(imageUrl: existingHeaderUrl)
                    print("Successfully deleted old header image")
                } catch {
                    print("Error deleting old header image: \(error.localizedDescription)")
                    // Continue with the update even if deletion fails
                }
            }
            headerUrlString = try await RealCompanyManager.shared.uploadHeaderImage(headerImage)
        } else {
            headerUrlString = company.headerImg // Keep existing header if no new one provided
        }
        
        // Upload new portfolio images
        let newPortfolioUrls = try await RealCompanyManager.shared.uploadPortfolioImages(portfolioImages)
        
        // Keep existing portfolio URLs if there are no new images
        let allPortfolioUrls = portfolioImages.isEmpty ? company.portfolioImages : newPortfolioUrls
        
        // If replacing portfolio images with new ones, delete the old ones
        if !portfolioImages.isEmpty && !company.portfolioImages.isEmpty {
            for imageUrl in company.portfolioImages {
                do {
                    try await RealCompanyManager.shared.deleteImageFromStorage(imageUrl: imageUrl)
                    print("Successfully deleted old portfolio image")
                } catch {
                    print("Error deleting old portfolio image: \(error.localizedDescription)")
                    // Continue with the update even if deletion fails
                }
            }
        }
        
        // Convert the array of tuples to a dictionary
        var socialMediaDict: [Company.SocialMedia: String] = [:]
        for link in socialMediaLinks {
            socialMediaDict[link.platform] = link.link
        }
        
        // Create a new company object with updated values but preserve the bookmarkedBy array
        let updatedCompany = Company(
            companyId: company.companyId,
            entrepId: company.entrepId,
            categoryIds: Array(selectedCategoryIds),
            name: companyName,
            logoImg: logoUrlString,
            headerImg: headerUrlString,
            aboutUs: aboutUs,
            dateFounded: formatDate(dateFounded),
            portfolioImages: allPortfolioUrls,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            workHours: workHours,
            services: services.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            socialMedias: socialMediaDict,
            businessModel: businessModel,
            website: website,
            isBookmarked: company.isBookmarked
        )
        
        // Preserve the existing bookmarkedBy array
        updatedCompany.bookmarkedBy = company.bookmarkedBy
        
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
    
    // Helper methods for uploading images
    private func uploadImage(_ image: UIImage, to folder: String) async throws -> String {
        switch folder {
        case "logos":
            return try await RealCompanyManager.shared.uploadLogoImage(image)
        case "headers":
            return try await RealCompanyManager.shared.uploadHeaderImage(image)
        default:
            throw NSError(domain: "AddCompanyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown folder: \(folder)"])
        }
    }
    
    private func uploadPortfolioImages(_ images: [UIImage]) async throws -> [String] {
        return try await RealCompanyManager.shared.uploadPortfolioImages(images)
    }
    
    // Error handling for the company parameter that was removed
    private func createCompany(company: Company) async throws {
        try await RealCompanyManager.shared.createCompany(company: company)
        try await EntrepreneurManager.shared.addCompany(company: company)
    }
}
