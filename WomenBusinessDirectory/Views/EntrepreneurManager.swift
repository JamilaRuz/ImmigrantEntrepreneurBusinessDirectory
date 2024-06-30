//
//  EntrepreneurManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Entrepreneur: Codable {
  var entrepId: String
  var fullName: String?
  var dateCreated: Date
  var email: String?
  var photoUrl: String?
  var bioDescr: String?
  var companyIds: [String] = []
  
  init(auth: AuthDataResultModel) {
    self.entrepId = auth.uid
    self.fullName = auth.fullName
    self.email = auth.email
    self.photoUrl = auth.photoUrl
    self.dateCreated = Date()
  }
  
  init(entrepId: String, fullName: String, email: String, bioDescr: String, companyIds: [String]) {
    self.entrepId = entrepId
    self.fullName = fullName
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
  
  private func entrepDocument(entrepId: String) -> DocumentReference {
    return entrepCollection.document(entrepId)
  }
  
  func createEntrepreneur(entrep: Entrepreneur) async throws {
    print("Creating entrepreneur...")
    try entrepDocument(entrepId: entrep.entrepId).setData(from: entrep, merge: false)
    print("Entrepreneur created!")
  }

  func getEntrepreneur(entrepId: String) async throws -> Entrepreneur {
    try await entrepDocument(entrepId: entrepId).getDocument(as: Entrepreneur.self)
  }
}
