//
//  CompanyManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
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
    let headerImg: String?
    let aboutUs: String
    let dateFounded: String
    let portfolioImages: [String]
    let address: String
    let city: String
    let phoneNum: String
    let email: String
    let workHours: String
    let services: [String]
    let socialMedia: [SocialMedia: String]?
    let businessModel: BusinessModel
    let website: String
    var bookmarkedBy: [String]
    let ownershipTypes: [OwnershipType]
    
    // Computed property to get the social media platforms
    var socialMedias: [SocialMedia] {
        return socialMedia?.keys.sorted { $0.rawValue < $1.rawValue } ?? []
    }
    
    var isBookmarked: Bool {
        get {
            if let currentUserId = try? AuthenticationManager.shared.getAuthenticatedUser().uid {
                return bookmarkedBy.contains(currentUserId)
            }
            return false
        }
    }
    
    enum BusinessModel: String, CaseIterable, Codable {
        case online
        case offline
        case hybrid
    }

    enum SocialMedia: String, CaseIterable, Codable {
        case facebook = "Facebook"
        case instagram = "Instagram"
        case twitter = "Twitter"
        case linkedin = "LinkedIn"
        case youtube = "YouTube"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .facebook: return "person.2"
            case .instagram: return "camera"
            case .twitter: return "message.fill"
            case .linkedin: return "briefcase.fill"
            case .youtube: return "play.rectangle.fill"
            case .other: return "link"
            }
        }
    }
    
    enum OwnershipType: String, Codable, CaseIterable {
        case femaleOwned = "Female Owned"
        case latinxOwned = "Latinx Owned"
        case asianOwned = "Asian Owned"
        case lgbtqOwned = "LGBTQ+ Owned"
    }
    
    enum WorkingHoursType: String, CaseIterable, Codable {
        case standard = "Mon - Fri 9am - 5pm"
        case allDay = "24/7"
        case custom = "Custom"
        
        var displayText: String {
            return self.rawValue
        }
    }
    
    init(companyId: String, entrepId: String, categoryIds: [String], name: String, logoImg: String?, headerImg: String?, aboutUs: String, dateFounded: String, portfolioImages: [String], address: String, city: String, phoneNum: String, email: String, workHours: String, services: [String], socialMedia: [SocialMedia: String]? = nil, businessModel: BusinessModel, website: String, ownershipTypes: [OwnershipType], isBookmarked: Bool = false) {
        self.companyId = companyId
        self.entrepId = entrepId
        self.categoryIds = categoryIds
        self.name = name
        self.logoImg = logoImg
        self.headerImg = headerImg
        self.aboutUs = aboutUs
        self.dateFounded = dateFounded
        self.portfolioImages = portfolioImages
        self.address = address
        self.city = city
        self.phoneNum = phoneNum
        self.email = email
        self.workHours = workHours
        self.services = services
        self.socialMedia = socialMedia
        self.businessModel = businessModel
        self.website = website
        
        // Initialize bookmarkedBy array
        if isBookmarked, let currentUserId = try? AuthenticationManager.shared.getAuthenticatedUser().uid {
            self.bookmarkedBy = [currentUserId]
        } else {
            self.bookmarkedBy = []
        }
        
        self.ownershipTypes = ownershipTypes
    }
}

protocol CompanyManager {
    func getCompanies() async throws -> [Company]
    func getCompaniesByCategory(categoryId: String) async throws -> [Company]
    func getCompany(companyId: String) async throws -> Company
    func createCompany(company: Company) async throws
    func updateCompany(company: Company) async throws
    func deleteCompany(companyId: String) async throws
    func updateBookmarkStatus(for company: Company, isBookmarked: Bool) async throws
    func getBookmarkedCompanies() async throws -> [Company]
    func uploadLogoImage(_ image: UIImage) async throws -> String
    func uploadHeaderImage(_ image: UIImage) async throws -> String
    func uploadPortfolioImages(_ images: [UIImage]) async throws -> [String]
}

final class RealCompanyManager: CompanyManager {
    
    static let shared = RealCompanyManager()
    private let db = Firestore.firestore()
    private let companiesCollection = Firestore.firestore().collection("companies")
    private let categoriesCollection = Firestore.firestore().collection("categories")
    private let storageRef = Storage.storage().reference()

    
    private init() {}
    
    private func companyDocument(companyId: String) -> DocumentReference {
        return companiesCollection.document(companyId)
    }
    
    func getCompanies() async throws -> [Company] {
        print("Fetching all companies...")
        let querySnapshot = try await companiesCollection.getDocuments()
        let companies = try querySnapshot.documents.map { try $0.data(as: Company.self) }
        print("Fetched \(companies.count) companies")
        print("Company details:")
        for company in companies {
            print("- \(company.name) (ID: \(company.companyId), Category IDs: \(company.categoryIds), Owner: \(company.entrepId))")
        }
        return companies
    }
    
    func getCompaniesByCategory(categoryId: String) async throws -> [Company] {
        print("Fetching companies for category: \(categoryId)")
        let querySnapshot = try await companiesCollection
            .whereField("categoryIds", arrayContains: categoryId)
            .getDocuments()
        let companies = try querySnapshot.documents.map { try $0.data(as: Company.self) }
        print("Fetched \(companies.count) companies for category \(categoryId)")
        print("Company details for category \(categoryId):")
        for company in companies {
            print("- \(company.name) (ID: \(company.companyId), Owner: \(company.entrepId))")
        }
        return companies
    }
    
    func getCompany(companyId: String) async throws -> Company {
        print("Getting company with id: \(companyId)...")
        let company = try await companyDocument(companyId: companyId).getDocument(as: Company.self)
        print("Company loaded! \(company)")
        return company
    }
    
    func createCompany(company: Company) async throws {
        print("Creating company...")
        
        let companyRef = companiesCollection.document()
        let updatedCompany = company
        updatedCompany.companyId = companyRef.documentID
        
        try companyRef.setData(from: updatedCompany)
        print("Company created with ID: \(updatedCompany.companyId)")
    }

    func deleteCompany(companyId: String) async throws {
        print("Deleting company with ID: \(companyId)")
        
        do {
            // First get the company to get all image URLs
            let company = try await getCompany(companyId: companyId)
            
            // Delete all associated images from Storage
            let imagesToDelete = [company.logoImg, company.headerImg].compactMap { $0 } + company.portfolioImages
            
            for imageUrl in imagesToDelete {
                do {
                    let storageRef = Storage.storage().reference(forURL: imageUrl)
                    try? await storageRef.delete()
                } catch {
                    print("Error deleting image \(imageUrl): \(error)")
                }
            }
            
            // Delete the company document
            let companyRef = companiesCollection.document(companyId)
            try await companyRef.delete()
            
            // Remove company ID from entrepreneur's list
            try await EntrepreneurManager.shared.removeCompany(companyId: companyId)
            
            print("Successfully deleted company and all associated data")
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
                print("Network error while deleting company: \(error.localizedDescription)")
                throw NSError(
                    domain: "CompanyManager",
                    code: error.code,
                    userInfo: [NSLocalizedDescriptionKey: "Network error while deleting company. Please check your internet connection and try again."]
                )
            } else {
                print("Error deleting company: \(error.localizedDescription)")
                throw error
            }
        }
    }
    
    func getBookmarkedCompanies() async throws -> [Company] {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
        let querySnapshot = try await companiesCollection
            .whereField("bookmarkedBy", arrayContains: currentUserId)
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
    
    func uploadHeaderImage(_ image: UIImage) async throws -> String {
      guard let imageData = image.jpegData(compressionQuality: 0.5) else {
        throw NSError(domain: "CompanyManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
      }

      let imageName = UUID().uuidString + ".jpg"
      let imageReference = storageRef.child("header_images/\(imageName)")

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
    
    func updateBookmarkStatus(for company: Company, isBookmarked: Bool) async throws {
        print("Updating bookmark status for company: \(company.companyId)")
        
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            let companyRef = companiesCollection.document(company.companyId)
            
            if isBookmarked {
                // Add user to bookmarkedBy array if not already present
                try await companyRef.updateData([
                    "bookmarkedBy": FieldValue.arrayUnion([currentUserId])
                ])
            } else {
                // Remove user from bookmarkedBy array
                try await companyRef.updateData([
                    "bookmarkedBy": FieldValue.arrayRemove([currentUserId])
                ])
            }
            print("Bookmark status successfully updated")
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
                print("Network error while updating bookmark status: \(error.localizedDescription)")
                throw NSError(
                    domain: "CompanyManager",
                    code: error.code,
                    userInfo: [NSLocalizedDescriptionKey: "Network error while updating bookmark. Please check your internet connection and try again."]
                )
            } else {
                print("Error updating bookmark status: \(error.localizedDescription)")
                throw error
            }
        }
    }
    
    func getCategories() async throws -> [Category] {
        let querySnapshot = try await categoriesCollection.getDocuments()
        return try querySnapshot.documents.map { try $0.data(as: Category.self) }
    }
    
    func updateCompany(company: Company) async throws {
        print("Updating company with id: \(company.companyId)...")
        
        let companyRef = companiesCollection.document(company.companyId)
        
        do {
            try companyRef.setData(from: company, merge: true)
            print("Company updated successfully!")
        } catch {
            print("Error updating company: \(error)")
            throw error
        }
    }
}
