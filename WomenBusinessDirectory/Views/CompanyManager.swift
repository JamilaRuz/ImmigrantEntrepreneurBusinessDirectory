//
//  CompanyManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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
  let logoImg: String
  let aboutUs: String
  let dateFounded: String
  let address: String
  let phoneNum: String
  let email: String
  let workHours: String
  let directions: String
  let socialMediaFacebook: String
  let socialMediaInsta: String
  
  init(companyId: String, entrepId: String, categoryIds: [String], name: String, logoImg: String, aboutUs: String, dateFounded: String, address: String, phoneNum: String, email: String, workHours: String, directions: String, socialMediaFacebook: String, socialMediaInsta: String) {
    self.companyId = companyId
    self.entrepId = entrepId
    self.categoryIds = categoryIds
    self.name = name
    self.logoImg = logoImg
    self.aboutUs = aboutUs
    self.dateFounded = dateFounded
    self.address = address
    self.phoneNum = phoneNum
    self.email = email
    self.workHours = workHours
    self.directions = directions
    self.socialMediaFacebook = socialMediaFacebook
    self.socialMediaInsta = socialMediaInsta
  }
}

final class CompanyManager {
  
  static let shared = CompanyManager()
  private init() {}
  
  private let companiesCollection = Firestore.firestore().collection("companies")
  
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
    
    //    try companyDocument(companyId: company.companyId).setData(from: company, merge: false)
    print("Company created!")
  }
  
  func getCompany(companyId: String) async throws -> Company {
    print("Getting company with id: \(companyId)...")
    let company = try await companyDocument(companyId: companyId).getDocument(as: Company.self)
    print("Company loaded! \(company)")
    return company
  }
  
  func getCompanies() async throws -> [Company?] {
    let querySnapshot = try await companiesCollection.getDocuments()
    return try querySnapshot.documents.map { try $0.data(as: Company.self) }
  }

}
