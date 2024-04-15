//
//  Company.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftData
import Foundation
import SwiftUI

@Model
class Company: Identifiable {
    @Attribute(.unique)
    var id = UUID()
    var name: String
    var logoImg: String
    var aboutUs: String
    var dateFounded: String
    var address: String
    var phoneNum: String
    var email: String
    var workHours: String
    var directions: String
    var category: Category
    var entrepreneur: Entrepreneur
    var isFavorite = false
    
    init(name: String, logoImg: String, aboutUs: String, dateFounded: String, entrepreneur: Entrepreneur, address: String, phoneNum: String, email: String, workHours: String, directions: String, category: Category, isFavorite: Bool) {
        self.name = name
        self.logoImg = logoImg
        self.dateFounded = dateFounded
        self.aboutUs = aboutUs
        self.entrepreneur = entrepreneur
        self.address = address
        self.phoneNum = phoneNum
        self.email = email
        self.workHours = workHours
        self.directions = directions
        self.category = category
        self.isFavorite = isFavorite
    }
}

struct Category: Codable, Hashable {
    var name: String
    var image: String
}
