////
////  Company.swift
////  WomenBusinessDirectory
////
////  Created by Jamila Ruzimetova on 4/12/24.
////
//
//import Foundation
//import SwiftUI
//
//class Company: Identifiable, Codable {
//  let id = UUID()
//  let name: String
//  let logoImg: String
//  let aboutUs: String
//  let dateFounded: String
//  let address: String
//  let phoneNum: String
//  let email: String
//  let workHours: String
//  let directions: String
//  let category: Category
//  let socialMediaFacebook: String
//  let socialMediaInsta: String
//  
//  var entrepreneur: Entrepreneur
//  
//  init(name: String, logoImg: String, aboutUs: String, dateFounded: String, address: String, phoneNum: String, email: String, workHours: String, directions: String, category: Category, socialMediaFacebook: String, socialMediaInsta: String, entrepreneur: Entrepreneur) {
//    self.name = name
//    self.logoImg = logoImg
//    self.dateFounded = dateFounded
//    self.aboutUs = aboutUs
//    self.address = address
//    self.phoneNum = phoneNum
//    self.email = email
//    self.workHours = workHours
//    self.directions = directions
//    self.category = category
//    self.socialMediaFacebook = socialMediaFacebook
//    self.socialMediaInsta = socialMediaInsta
//    self.entrepreneur = entrepreneur
//  }
//  
//  enum CodingKeys: String, CodingKey {
//     case id
//     case name
//     case logoImg
//     case aboutUs
//     case dateFounded
//     case address
//     case phoneNum
//     case email
//     case workHours
//     case directions
//     case category
//     case socialMediaFacebook
//     case socialMediaInsta
//     case entrepreneur
//   }
//
//   required init(from decoder: Decoder) throws {
//     let container = try decoder.container(keyedBy: CodingKeys.self)
//     id = try container.decode(UUID.self, forKey: .id)
//     name = try container.decode(String.self, forKey: .name)
//     logoImg = try container.decode(String.self, forKey: .logoImg)
//     aboutUs = try container.decode(String.self, forKey: .aboutUs)
//     dateFounded = try container.decode(String.self, forKey: .dateFounded)
//     address = try container.decode(String.self, forKey: .address)
//     phoneNum = try container.decode(String.self, forKey: .phoneNum)
//     email = try container.decode(String.self, forKey: .email)
//     workHours = try container.decode(String.self, forKey: .workHours)
//     directions = try container.decode(String.self, forKey: .directions)
//     category = try container.decode(Category.self, forKey: .category)
//     socialMediaFacebook = try container.decode(String.self, forKey: .socialMediaFacebook)
//     socialMediaInsta = try container.decode(String.self, forKey: .socialMediaInsta)
//     entrepreneur = try container.decode(Entrepreneur.self, forKey: .entrepreneur)
//   }
//
//   func encode(to encoder: Encoder) throws {
//     var container = encoder.container(keyedBy: CodingKeys.self)
//     try container.encode(id, forKey: .id)
//     try container.encode(name, forKey: .name)
//     try container.encode(logoImg, forKey: .logoImg)
//     try container.encode(aboutUs, forKey: .aboutUs)
//     try container.encode(dateFounded, forKey: .dateFounded)
//     try container.encode(address, forKey: .address)
//     try container.encode(phoneNum, forKey: .phoneNum)
//     try container.encode(email, forKey: .email)
//     try container.encode(workHours, forKey: .workHours)
//     try container.encode(directions, forKey: .directions)
//     try container.encode(category, forKey: .category)
//     try container.encode(socialMediaFacebook, forKey: .socialMediaFacebook)
//     try container.encode(socialMediaInsta, forKey: .socialMediaInsta)
//     try container.encode(entrepreneur, forKey: .entrepreneur)
//   }
//  
//}
//
//struct Category: Codable, Hashable {
//  var name: String
//  var image: String
//}
