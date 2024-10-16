//
//  EntrepreneurManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct Entrepreneur: Codable, Hashable {
  var entrepId: String
  var fullName: String?
  var profileUrl: String?
  var dateCreated: Date
  var email: String?
  var bioDescr: String?
  var companyIds: [String] = []
  
  init(auth: AuthDataResultModel) {
    self.entrepId = auth.uid
    self.fullName = auth.fullName
    self.email = auth.email
    self.dateCreated = Date()
  }
  
  init(entrepId: String, fullName: String, profileUrl: String?, email: String, bioDescr: String, companyIds: [String]) {
    self.entrepId = entrepId
    self.fullName = fullName
    self.profileUrl = profileUrl
    self.email = email
    self.bioDescr = bioDescr
    self.companyIds = companyIds
    self.dateCreated = Date()
  }
}

final class EntrepreneurManager {
  
  static let shared = EntrepreneurManager()
  private init() {}
  
  private let entrepCollection = Firestore.firestore().collection("entrepreneurs")
  
  private let storage = Storage.storage().reference()
  
  private func entrepDocument(entrepId: String) -> DocumentReference {
    print("Creating document reference for entrepId: \(entrepId)")
    return entrepCollection.document(entrepId)
  }
  
  func createEntrepreneur(entrep: Entrepreneur) async throws {
    guard !entrep.entrepId.isEmpty else {
        throw NSError(domain: "EntrepreneurManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Entrepreneur ID cannot be empty"])
    }
    print("Creating entrepreneur...")
    try entrepDocument(entrepId: entrep.entrepId).setData(from: entrep, merge: false)
    print("Entrepreneur created!")
  }

  func getEntrepreneur(entrepId: String) async throws -> Entrepreneur {
    try await entrepDocument(entrepId: entrepId).getDocument(as: Entrepreneur.self)
  }
  
  func addCompany(company: Company) async throws {
    var entrep = try await getEntrepreneur(entrepId: company.entrepId)
    entrep.companyIds.append(company.companyId)
    try entrepDocument(entrepId: entrep.entrepId).setData(from: entrep, merge: false)
  }
  
  func uploadProfileImage(_ image: UIImage, for entrepreneur: Entrepreneur) async throws -> String {
    guard let imageData = image.jpegData(compressionQuality: 0.5) else {
      throw NSError(domain: "EntrepreneurManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
    }

    let imageName = UUID().uuidString + ".jpg"
    let imageReference = storage.child("profile_images/\(imageName)")

    _ = try await imageReference.putDataAsync(imageData)
    let downloadURL = try await imageReference.downloadURL()

    return downloadURL.absoluteString
  }

  func updateEntrepreneur(_ entrepreneur: Entrepreneur) async throws {
    guard !entrepreneur.entrepId.isEmpty else {
        throw NSError(domain: "EntrepreneurManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Entrepreneur ID cannot be empty"])
    }
    try entrepDocument(entrepId: entrepreneur.entrepId).setData(from: entrepreneur, merge: true)
  }
}
