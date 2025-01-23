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
import FirebaseAuth

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
  
  private let storageRef = Storage.storage().reference()
  
  private func entrepDocument(entrepId: String) -> DocumentReference {
    print("Creating document reference for entrepId: \(entrepId)")
    return entrepCollection.document(entrepId)
  }
  
func createEntrepreneur(fullName: String, email: String) async throws {
    guard let uid = Auth.auth().currentUser?.uid else {
        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
    }
    print("Creating entrepreneur with uid: \(uid)")
    let entrepreneur = Entrepreneur(entrepId: uid, fullName: fullName, profileUrl: nil, email: email, bioDescr: "", companyIds: [])
    print("Entrepreneur created: \(entrepreneur)")
    let encodedEntrepreneur = try Firestore.Encoder().encode(entrepreneur)
    try await entrepDocument(entrepId: uid).setData(encodedEntrepreneur)
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
    let imageReference = storageRef.child("profile_images/\(imageName)")

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

  func updateEntrepreneur(_ entrepreneur: Entrepreneur) async throws {
    guard !entrepreneur.entrepId.isEmpty else {
        throw NSError(domain: "EntrepreneurManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Entrepreneur ID cannot be empty"])
    }
    try entrepDocument(entrepId: entrepreneur.entrepId).setData(from: entrepreneur, merge: true)
  }
}
