//
//  Entrepreneur.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftData
import Foundation

@Model
class Entrepreneur: Identifiable, Codable {
  let id: String
  var fullName: String
  let email: String
  var bioDescr: String?
  
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
  
  init(id: String, fullName: String, email: String, bioDescr: String? = nil, companies: [Company] = []) {
    self.id = id
    self.fullName = fullName
    self.email = email
    self.bioDescr = bioDescr
    self.companies = companies
  }
  
  // Implement the encode(to:) method to conform to Encodable
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(fullName, forKey: .fullName)
    try container.encode(email, forKey: .email)
    try container.encode(bioDescr, forKey: .bioDescr)
    try container.encode(profileImage, forKey: .profileImage)
    try container.encode(companies, forKey: .companies)
  }

  // Implement the init(from:) method to conform to Decodable
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    fullName = try container.decode(String.self, forKey: .fullName)
    email = try container.decode(String.self, forKey: .email)
    bioDescr = try container.decode(String?.self, forKey: .bioDescr)
    profileImage = try container.decode(Data?.self, forKey: .profileImage)
    companies = try container.decode([Company].self, forKey: .companies)
  }

  // Define the coding keys for the properties
  private enum CodingKeys: String, CodingKey {
    case id
    case fullName
    case email
    case bioDescr
    case profileImage
    case companies
  }
}
