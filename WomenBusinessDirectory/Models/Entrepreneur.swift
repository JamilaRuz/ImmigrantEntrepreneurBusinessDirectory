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
    @Attribute(.unique)
    var id = UUID()
    var firstName: String
    var lastName: String
    var image: String
    var bioDescr: String
    
    init(firstName: String, lastName: String, image: String, bioDescr: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.image = image
        self.bioDescr = bioDescr
    }
}
