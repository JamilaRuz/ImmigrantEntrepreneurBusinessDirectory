//
//  CompanyManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

// Helper to access AuthenticationManager safely from non-MainActor contexts
@MainActor
func getUserId() throws -> String {
    return try AuthenticationManager.shared.getAuthenticatedUser().uid
}

// Non-MainActor helper for synchronous contexts
func getUserIdSync() -> String? {
    return Auth.auth().currentUser?.uid
}

class Company: Codable, Hashable, Equatable, Identifiable {
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.companyId == rhs.companyId &&
               lhs.name == rhs.name &&
               lhs.logoImg == rhs.logoImg &&
               lhs.headerImg == rhs.headerImg &&
               lhs.aboutUs == rhs.aboutUs &&
               lhs.portfolioImages == rhs.portfolioImages &&
               lhs.address == rhs.address &&
               lhs.city == rhs.city &&
               lhs.phoneNum == rhs.phoneNum &&
               lhs.email == rhs.email &&
               lhs.workHours == rhs.workHours &&
               lhs.services == rhs.services &&
               lhs.website == rhs.website &&
               lhs.ownershipTypes == rhs.ownershipTypes &&
               lhs.categoryIds == rhs.categoryIds
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(companyId)
        hasher.combine(name)
        hasher.combine(logoImg)
        hasher.combine(headerImg)
        hasher.combine(address)
        hasher.combine(city)
        hasher.combine(email)
        hasher.combine(phoneNum)
        hasher.combine(website)
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
    let socialMedias: [SocialMedia: String]?
    let businessModel: BusinessModel
    let website: String
    var bookmarkedBy: [String]
    let ownershipTypes: [OwnershipType]
    
    // Computed property to get the social media platforms
    var socialMediaPlatforms: [SocialMedia] {
        return socialMedias?.keys.sorted { $0.rawValue < $1.rawValue } ?? []
    }
    
    var isBookmarked: Bool {
        get {
            // Use the synchronous helper function
            if let currentUserId = getUserIdSync() {
                return bookmarkedBy.contains(currentUserId)
            }
            return false
        }
    }
    
    // Custom Codable implementation to handle socialMedias field
    enum CodingKeys: String, CodingKey {
        case companyId, entrepId, categoryIds, name, logoImg, headerImg, aboutUs
        case dateFounded, portfolioImages, address, city, phoneNum, email, workHours
        case services, socialMedias, businessModel, website, bookmarkedBy, ownershipTypes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular properties
        companyId = try container.decode(String.self, forKey: .companyId)
        entrepId = try container.decode(String.self, forKey: .entrepId)
        categoryIds = try container.decode([String].self, forKey: .categoryIds)
        name = try container.decode(String.self, forKey: .name)
        logoImg = try container.decodeIfPresent(String.self, forKey: .logoImg)
        headerImg = try container.decodeIfPresent(String.self, forKey: .headerImg)
        aboutUs = try container.decode(String.self, forKey: .aboutUs)
        dateFounded = try container.decode(String.self, forKey: .dateFounded)
        portfolioImages = try container.decode([String].self, forKey: .portfolioImages)
        address = try container.decode(String.self, forKey: .address)
        city = try container.decode(String.self, forKey: .city)
        phoneNum = try container.decode(String.self, forKey: .phoneNum)
        email = try container.decode(String.self, forKey: .email)
        workHours = try container.decode(String.self, forKey: .workHours)
        services = try container.decode([String].self, forKey: .services)
        businessModel = try container.decode(BusinessModel.self, forKey: .businessModel)
        website = try container.decode(String.self, forKey: .website)
        bookmarkedBy = try container.decodeIfPresent([String].self, forKey: .bookmarkedBy) ?? []
        ownershipTypes = try container.decode([OwnershipType].self, forKey: .ownershipTypes)
        
        // Special handling for socialMedias - it can be a dictionary or might be missing
        if container.contains(.socialMedias) {
            do {
                // Try to decode as a dictionary where keys are platform name strings and values are URL strings
                let socialMediaDict = try container.decode([String: String].self, forKey: .socialMedias)
                
                // Convert string keys to SocialMedia enum values
                var typedSocialMedias: [SocialMedia: String] = [:]
                
                for (key, value) in socialMediaDict {
                    if let platform = SocialMedia(rawValue: key) {
                        typedSocialMedias[platform] = value
                    } else if let platform = SocialMedia.allCases.first(where: { $0.rawValue.lowercased() == key.lowercased() }) {
                        // Try case-insensitive matching as a fallback
                        typedSocialMedias[platform] = value
                    }
                }
                
                self.socialMedias = typedSocialMedias.isEmpty ? nil : typedSocialMedias
            } catch {
                print("Error decoding socialMedias field: \(error)")
                self.socialMedias = nil
            }
        } else {
            self.socialMedias = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode regular properties
        try container.encode(companyId, forKey: .companyId)
        try container.encode(entrepId, forKey: .entrepId)
        try container.encode(categoryIds, forKey: .categoryIds)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(logoImg, forKey: .logoImg)
        try container.encodeIfPresent(headerImg, forKey: .headerImg)
        try container.encode(aboutUs, forKey: .aboutUs)
        try container.encode(dateFounded, forKey: .dateFounded)
        try container.encode(portfolioImages, forKey: .portfolioImages)
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(phoneNum, forKey: .phoneNum)
        try container.encode(email, forKey: .email)
        try container.encode(workHours, forKey: .workHours)
        try container.encode(services, forKey: .services)
        try container.encode(businessModel, forKey: .businessModel)
        try container.encode(website, forKey: .website)
        try container.encode(bookmarkedBy, forKey: .bookmarkedBy)
        try container.encode(ownershipTypes, forKey: .ownershipTypes)
        
        // Special handling for socialMedias - convert to string-keyed dictionary
        if let socialMedias = socialMedias, !socialMedias.isEmpty {
            let stringKeyed = Dictionary(uniqueKeysWithValues: socialMedias.map { (key, value) in
                return (key.rawValue, value)
            })
            try container.encode(stringKeyed, forKey: .socialMedias)
        }
    }
    
    init(companyId: String, entrepId: String, categoryIds: [String], name: String, logoImg: String?, headerImg: String?, aboutUs: String, dateFounded: String, portfolioImages: [String], address: String, city: String, phoneNum: String, email: String, workHours: String, services: [String], socialMedias: [SocialMedia: String]? = nil, businessModel: BusinessModel, website: String, ownershipTypes: [OwnershipType], isBookmarked: Bool = false) {
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
        self.socialMedias = socialMedias
        self.businessModel = businessModel
        self.website = website
        
        // Initialize bookmarkedBy array using synchronous helper
        if isBookmarked, let currentUserId = getUserIdSync() {
            self.bookmarkedBy = [currentUserId]
        } else {
            self.bookmarkedBy = []
        }
        
        self.ownershipTypes = ownershipTypes
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
        case blackOwned = "Black Owned"
    }
    
    enum WorkingHoursType: String, CaseIterable, Codable {
        case standard = "Mon - Fri 9am - 5pm"
        case allDay = "24/7"
        case custom = "Custom"
        
        var displayText: String {
            return self.rawValue
        }
    }
}

protocol CompanyManager {
    func getCompanies(source: FirestoreSource) async throws -> [Company]
    func getCompaniesByCategory(categoryId: String, source: FirestoreSource) async throws -> [Company]
    func getCompany(companyId: String) async throws -> Company
    func createCompany(company: Company) async throws
    func updateCompany(company: Company) async throws
    func deleteCompany(companyId: String) async throws
    func updateBookmarkStatus(for company: Company, isBookmarked: Bool) async throws
    func getBookmarkedCompanies() async throws -> [Company]
    func uploadLogoImage(_ image: UIImage) async throws -> String
    func uploadHeaderImage(_ image: UIImage) async throws -> String
    func uploadPortfolioImages(_ images: [UIImage]) async throws -> [String]
    func deleteImageFromStorage(imageUrl: String) async throws
    func checkImageExistsInStorage(imageUrl: String) async -> Bool
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
    
    func getCompanies(source: FirestoreSource = .default) async throws -> [Company] {
        print("RealCompanyManager: Fetching all companies with source: \(source)...")
        do {
            let querySnapshot = try await companiesCollection.getDocuments(source: source)
            print("RealCompanyManager: Received document snapshot with \(querySnapshot.documents.count) documents")
            
            let companies = try querySnapshot.documents.map { document -> Company in
                do {
                    return try document.data(as: Company.self)
                } catch {
                    print("RealCompanyManager: Error decoding company from document \(document.documentID): \(error)")
                    throw error
                }
            }
            
            print("RealCompanyManager: Successfully decoded \(companies.count) companies")
            print("RealCompanyManager: Company details:")
            for company in companies {
                print("- \(company.name) (ID: \(company.companyId), Category IDs: \(company.categoryIds), Owner: \(company.entrepId))")
            }
            return companies
        } catch {
            print("RealCompanyManager: Error fetching companies: \(error)")
            throw error
        }
    }
    
    func getCompaniesByCategory(categoryId: String, source: FirestoreSource = .default) async throws -> [Company] {
        print("Fetching companies for category: \(categoryId) with source: \(source)")
        let querySnapshot = try await companiesCollection
            .whereField("categoryIds", arrayContains: categoryId)
            .getDocuments(source: source)
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
                    try await storageRef.delete()
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
        // Call the MainActor-aware helper function
        let currentUserId = try await MainActor.run { try getUserId() }
        
        let querySnapshot = try await companiesCollection
            .whereField("bookmarkedBy", arrayContains: currentUserId)
            .getDocuments()
        
        return try querySnapshot.documents.map { try $0.data(as: Company.self) }
    }
    
    func uploadLogoImage(_ image: UIImage) async throws -> String {
      // Resize image to appropriate dimensions for logos (max 400x400 while preserving aspect ratio)
      let resizedImage = image.preparingForUpload(maxDimension: 400)
      
      guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
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
      // Resize image to appropriate dimensions for headers (max 1200 width while preserving aspect ratio)
      let resizedImage = image.preparingForUpload(maxDimension: 1200)
      
      guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
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
            // Resize image to appropriate dimensions for portfolio (max 800px while preserving aspect ratio)
            let resizedImage = image.preparingForUpload(maxDimension: 800)
            
            guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
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
            // Call the MainActor-aware helper function
            let currentUserId = try await MainActor.run { try getUserId() }
            
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
    
    func deleteImageFromStorage(imageUrl: String) async throws {
        do {
            print("Starting to delete image from storage: \(imageUrl)")
            
            // Extract filename from URL for better logging
            let filename = URL(string: imageUrl)?.lastPathComponent ?? "unknown"
            
            let storageRef = Storage.storage().reference(forURL: imageUrl)
            try await storageRef.delete()
            
            // After successfully deleting, verify the image no longer exists
            print("✅ Successfully deleted image \(filename) from storage")
            
            // You could add analytics event here if needed
            // Analytics.logEvent("image_deleted", parameters: ["status": "success"])
        } catch let error as NSError {
            // Check if it's an object not found error (the file doesn't exist)
            if error.code == StorageErrorCode.objectNotFound.rawValue {
                // The file didn't exist - might have been already deleted
                print("⚠️ Image was already deleted or doesn't exist: \(imageUrl)")
                return // Don't throw an error in this case
            }
            
            print("❌ Error deleting image from storage: \(error.localizedDescription)")
            // Analytics.logEvent("image_deleted", parameters: ["status": "error", "error": error.localizedDescription])
            
            throw NSError(
                domain: "CompanyManager",
                code: error.code,
                userInfo: [NSLocalizedDescriptionKey: "Error deleting image from storage: \(error.localizedDescription)"]
            )
        }
    }
    
    func checkImageExistsInStorage(imageUrl: String) async -> Bool {
        do {
            let storageRef = Storage.storage().reference(forURL: imageUrl)
            // We only need metadata to check existence, not the whole image
            _ = try await storageRef.getMetadata()
            return true
        } catch {
            print("Error checking image existence: \(error.localizedDescription)")
            return false
        }
    }
}
