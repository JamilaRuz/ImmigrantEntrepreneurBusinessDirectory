//
//  Entrepreneur.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftData
import Foundation

@Model
class Entrepreneur: Identifiable {
  let id: String
  var fullName: String
  let email: String
  let bioDescr: String
  
  @Attribute(.externalStorage)
  var profileImage: Data?
  
  var initials: String {
    let formatter = PersonNameComponentsFormatter()
    if let components = formatter.personNameComponents(from: fullName) {
      formatter.style = .abbreviated
      return formatter.string(from: components)
    }
    return ""
  }
  
  @Relationship(deleteRule: .cascade, inverse: \Company.entrepreneur)
  var companies: [Company]
  
  init(id: String, fullName: String, email: String, bioDescr: String, companies: [Company]) {
    self.id = id
    self.fullName = fullName
    self.email = email
    self.bioDescr = bioDescr
    self.companies = companies
  }
}

//extension Entrepreneur {
//  static var MOCK_USER: Entrepreneur {
//    Entrepreneur(id: UUID().uuidString, fullName: "Jamila Ruzimetova", email: "test@gmail.com", bioDescr: "I am a software engineer",  companies: [])
//  }
//}
