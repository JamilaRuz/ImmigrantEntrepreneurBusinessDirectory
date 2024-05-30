//
//  Entrepreneur.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import Foundation
import SwiftData

@Model
class Entrepreneur: Identifiable {
    @Attribute(.unique) var id = UUID()
    var fullName: String
    var image: String
    var bioDescr: String
    var companies: [Company]
    
  init(fullName: String, image: String, bioDescr: String, companies: [Company]) {
        self.fullName = fullName
        self.image = image
        self.bioDescr = bioDescr
        self.companies = companies
    }
}
