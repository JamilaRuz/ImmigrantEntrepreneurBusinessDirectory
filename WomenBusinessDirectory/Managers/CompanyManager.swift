//
//  CompanyManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


class Company: Codable, Hashable, Equatable, Identifiable {
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.companyId == rhs.companyId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(companyId)
    }
    
    var companyId: String
    let entrepId: String
    let categoryIds: [String]
    let name: String
    let logoImg: String?
    let aboutUs: String
    let dateFounded: String
    let portfolioImages: [String]
    let address: String
    let city: String
    let phoneNum: String
    let email: String
    let workHours: String
    let services: [String]
    let socialMediaFacebook: String
    let socialMediaInsta: String
    let businessModel: BusinessModel
    let website: String
    var isBookmarked: Bool
    let ownershipTypes: [OwnershipType]
    
    init(companyId: String, entrepId: String, categoryIds: [String], name: String, logoImg: String?, aboutUs: String, dateFounded: String, portfolioImages: [String], address: String, city: String, phoneNum: String, email: String, workHours: String, services: [String], socialMediaFacebook: String, socialMediaInsta: String, businessModel: BusinessModel, website: String, ownershipTypes: [OwnershipType], isBookmarked: Bool = false) {
        self.companyId = companyId
        self.entrepId = entrepId
        self.categoryIds = categoryIds
        self.name = name
        self.logoImg = logoImg
        self.aboutUs = aboutUs
        self.dateFounded = dateFounded
        self.portfolioImages = portfolioImages
        self.address = address
        self.city = city
        self.phoneNum = phoneNum
        self.email = email
        self.workHours = workHours
        self.services = services
        self.socialMediaFacebook = socialMediaFacebook
        self.socialMediaInsta = socialMediaInsta
        self.businessModel = businessModel
        self.website = website
        self.isBookmarked = isBookmarked
        self.ownershipTypes = ownershipTypes
    }
    
    enum BusinessModel: String, CaseIterable, Codable {
        case online
        case offline
        case hybrid
    }
    
    enum OwnershipType: String, Codable, CaseIterable {
        case femaleOwned = "Female Owned"
        case latinxOwned = "Latinx Owned"
        case asianOwned = "Asian Owned"
        case lgbtqOwned = "LGBTQ+ Owned"
    }
}

protocol CompanyManager {
    func createCompany(company: Company) async throws
    func getCompany(companyId: String) async throws -> Company
    func getCompanies() async throws -> [Company]
    func getCompaniesByCategory(categoryId: String) async throws -> [Company]
}

final class RealCompanyManager: CompanyManager {
    
    static let shared = RealCompanyManager()
    private init() {}
    
    private let companiesCollection = Firestore.firestore().collection("companies")
    private let categoriesCollection = Firestore.firestore().collection("categories")
    private let storageRef = Storage.storage().reference()

    
    private func companyDocument(companyId: String) -> DocumentReference {
        return companiesCollection.document(companyId)
    }
    
    func createCompany(company: Company) async throws {
        print("Creating company...")
        
        let companyRef = companiesCollection.document()
        company.companyId = companyRef.documentID
        
        try companyRef.setData(from: company) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(company.companyId)")
            }
        }
        
        print("Company created!")
    }
    
    func getCompany(companyId: String) async throws -> Company {
        print("Getting company with id: \(companyId)...")
        let company = try await companyDocument(companyId: companyId).getDocument(as: Company.self)
        print("Company loaded! \(company)")
        return company
    }
    
    func getCompanies() async throws -> [Company] {
        let querySnapshot = try await companiesCollection.getDocuments()
        return try querySnapshot.documents.map { try $0.data(as: Company.self) }
    }
    
    func getCompaniesByCategory(categoryId: String) async throws -> [Company] {
        let querySnapshot = try await companiesCollection
            .whereField("categoryIds", arrayContains: categoryId)
            .getDocuments()
        return try querySnapshot.documents.map { try $0.data(as: Company.self) }
    }
    
    func getBookmarkedCompanies() async throws -> [Company] {
        let querySnapshot = try await companiesCollection
            .whereField("isBookmarked", isEqualTo: true)
            .getDocuments()
        
        return try querySnapshot.documents.map { try $0.data(as: Company.self) }
    }
    
    func uploadLogoImage(_ image: UIImage) async throws -> String {
      guard let imageData = image.jpegData(compressionQuality: 0.5) else {
        throw NSError(domain: "CompanyManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
      }

      let imageName = UUID().uuidString + ".jpg"
      let imageReference = storageRef.child("logo_images/\(imageName)")

      do {
        // Attempt to upload the image data
        _ = try await imageReference.putDataAsync(imageData)
        
        // If successful, get the download URL
        let downloadURL = try await imageReference.downloadURL()
        
        // Return the URL as a string
        return downloadURL.absoluteString
      } catch {
        // Handle any errors that occur during upload
        print("Error uploading image: \(error.localizedDescription)")
        throw error
      }
    }
    
    func uploadPortfolioImages(_ images: [UIImage]) async throws -> [String] {
        var uploadedImageURLs: [String] = []

        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                throw NSError(domain: "CompanyManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
            }

            let imageName = UUID().uuidString + ".jpg"
            let imageReference = storageRef.child("portfolio_images/\(imageName)")

            do {
                // Attempt to upload the image data
                _ = try await imageReference.putDataAsync(imageData)

                // If successful, get the download URL
                let downloadURL = try await imageReference.downloadURL()

                // Append the URL as a string to the list
                uploadedImageURLs.append(downloadURL.absoluteString)
            } catch {
                // Handle any errors that occur during upload
                print("Error uploading image: \(error.localizedDescription)")
                throw error
            }
        }

        // Return the list of URLs
        return uploadedImageURLs
    }
    
    func updateBookmarkStatus(for company: Company, isBookmarked: Bool) {
        let companyRef = companiesCollection.document(company.companyId)
        companyRef.updateData(["isBookmarked": isBookmarked]) { error in
            if let error = error {
                print("Error updating bookmark status: \(error)")
            } else {
                print("Bookmark status successfully updated")
            }
        }
    }
    
    func getCategories() async throws -> [Category] {
        let querySnapshot = try await categoriesCollection.getDocuments()
        return try querySnapshot.documents.map { try $0.data(as: Category.self) }
    }
}
