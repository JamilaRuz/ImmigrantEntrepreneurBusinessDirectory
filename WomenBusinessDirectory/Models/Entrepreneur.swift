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
  @Attribute(.unique)
  var id = UUID()
  
  var fullName: String
  
  @Attribute(.externalStorage)
  var profileImage: Data?
  
  var bioDescr: String
  
  @Relationship(deleteRule: .cascade, inverse: \Company.entrepreneur)
  var companies: [Company]
  
  init(fullName: String, bioDescr: String, companies: [Company]) {
    self.fullName = fullName
    self.bioDescr = bioDescr
    self.companies = companies
  }
}
