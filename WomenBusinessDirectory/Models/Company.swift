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
  @Attribute(.unique) var id = UUID()
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
  var socialMediaFacebook: String
  var socialMediaInsta: String
  
  var entrepreneur: Entrepreneur
  
  init(name: String, logoImg: String, aboutUs: String, dateFounded: String, address: String, phoneNum: String, email: String, workHours: String, directions: String, category: Category, socialMediaFacebook: String, socialMediaInsta: String, entrepreneur: Entrepreneur) {
    self.name = name
    self.logoImg = logoImg
    self.dateFounded = dateFounded
    self.aboutUs = aboutUs
    self.address = address
    self.phoneNum = phoneNum
    self.email = email
    self.workHours = workHours
    self.directions = directions
    self.category = category
    self.socialMediaFacebook = socialMediaFacebook
    self.socialMediaInsta = socialMediaInsta
    self.entrepreneur = entrepreneur
  }
}

struct Category: Codable, Hashable {
  var name: String
  var image: String
}
