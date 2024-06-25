//
//  EntrepreneurManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Entrepreneur {
  var entrepId: String
  var fullName: String
  var dateCreated: Date?
  var email: String
  var photoUrl: String?
  var bioDescr: String?
  var companyIds: [String] = []
}

final class EntrepreneurManager {
  
  static let shared = EntrepreneurManager()
  private init() {}
  
  func createEntrepreneur(auth: AuthDataResultModel, fullName: String) async throws {
    var entrepData: [String: Any] = [
      "entrep_id": auth.uid,
      "date_created": Date(),
      "full_name": fullName,
    ]
    if let email = auth.email {
      entrepData["email"] = email
    }
    
    print("Creating entrepreneur...")
    try await Firestore.firestore().collection("entrepreneurs").document(auth.uid).setData(entrepData, merge: false)
    print("Entrepreneur created!")
  }
  
  func getEntrepreneur(entrepId: String) async throws -> Entrepreneur {
    let snapshot = try await Firestore.firestore().collection("entrepreneurs").document(entrepId).getDocument()
    guard let data = snapshot.data(), let entrepId = data["entrep_id"] as? String else {
      throw URLError(.badServerResponse)
    }
    
    let fullName = data["full_name"] as! String
    let dateCreated = data["date_created"] as? Date
    let email = data["email"] as! String
    let photoUrl = data["photo_url"] as? String
    let bioDescr = data["bio_descr"] as? String
    let companyIds = data["company_ids"] as? [String] ?? []
    
    return Entrepreneur(entrepId: entrepId, fullName: fullName, dateCreated: dateCreated, email: email, photoUrl: photoUrl, bioDescr: bioDescr, companyIds: companyIds)
  }
  
}
