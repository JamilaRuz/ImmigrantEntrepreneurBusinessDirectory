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


class Company: Codable, Hashable, Equatable {
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
    let phoneNum: String
    let email: String
    let workHours: String
    let services: [String]
    let socialMediaFacebook: String
    let socialMediaInsta: String
    let businessModel: BusinessModel
    let website: String
    
    init(companyId: String, entrepId: String, categoryIds: [String], name: String, logoImg: String?, aboutUs: String, dateFounded: String, portfolioImages: [String], address: String, phoneNum: String, email: String, workHours: String, services: [String], socialMediaFacebook: String, socialMediaInsta: String, businessModel: BusinessModel, website: String) {
        self.companyId = companyId
        self.entrepId = entrepId
        self.categoryIds = categoryIds
        self.name = name
        self.logoImg = logoImg
        self.aboutUs = aboutUs
        self.dateFounded = dateFounded
        self.portfolioImages = portfolioImages
        self.address = address
        self.phoneNum = phoneNum
        self.email = email
        self.workHours = workHours
        self.services = services
        self.socialMediaFacebook = socialMediaFacebook
        self.socialMediaInsta = socialMediaInsta
        self.businessModel = businessModel
        self.website = website
    }
    
    enum BusinessModel: String, CaseIterable, Codable {
        case online
        case offline
        case hybrid
    }
    
    enum CodingKeys: String, CodingKey {
        case companyId
        case entrepId
        case categoryIds
        case name
        case logoImg
        case aboutUs
        case dateFounded
        case portfolioImages
        case address
        case phoneNum
        case email
        case workHours
        case services
        case socialMediaFacebook
        case socialMediaInsta
        case businessModel
        case website
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        companyId = try container.decode(String.self, forKey: .companyId)
        entrepId = try container.decode(String.self, forKey: .entrepId)
        categoryIds = try container.decode([String].self, forKey: .categoryIds)
        name = try container.decode(String.self, forKey: .name)
        logoImg = try container.decodeIfPresent(String.self, forKey: .logoImg)
        aboutUs = try container.decode(String.self, forKey: .aboutUs)
        dateFounded = try container.decode(String.self, forKey: .dateFounded)
        portfolioImages = try container.decode([String].self, forKey: .portfolioImages)
        address = try container.decode(String.self, forKey: .address)
        phoneNum = try container.decode(String.self, forKey: .phoneNum)
        email = try container.decode(String.self, forKey: .email)
        workHours = try container.decode(String.self, forKey: .workHours)
        services = try container.decode([String].self, forKey: .services)
        socialMediaFacebook = try container.decode(String.self, forKey: .socialMediaFacebook)
        socialMediaInsta = try container.decode(String.self, forKey: .socialMediaInsta)
        businessModel = try container.decode(BusinessModel.self, forKey: .businessModel)
        website = try container.decode(String.self, forKey: .website)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(companyId, forKey: .companyId)
        try container.encode(entrepId, forKey: .entrepId)
        try container.encode(categoryIds, forKey: .categoryIds)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(logoImg, forKey: .logoImg)
        try container.encode(aboutUs, forKey: .aboutUs)
        try container.encode(dateFounded, forKey: .dateFounded)
        try container.encode(portfolioImages, forKey: .portfolioImages)
        try container.encode(address, forKey: .address)
        try container.encode(phoneNum, forKey: .phoneNum)
        try container.encode(email, forKey: .email)
        try container.encode(workHours, forKey: .workHours)
        try container.encode(services, forKey: .services)
        try container.encode(socialMediaFacebook, forKey: .socialMediaFacebook)
        try container.encode(socialMediaInsta, forKey: .socialMediaInsta)
        try container.encode(businessModel, forKey: .businessModel)
        try container.encode(website, forKey: .website)
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
}
