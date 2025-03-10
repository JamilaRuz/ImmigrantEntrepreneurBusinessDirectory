//
//  StubData.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/30/24.
//

import Foundation
import UIKit
import FirebaseFirestore

class StubCompanyManager: CompanyManager {
  func getCompanies(source: FirestoreSource = .default) async throws -> [Company] {
    createStubCompanies()
  }
  
  func getCompaniesByCategory(categoryId: String, source: FirestoreSource = .default) async throws -> [Company] {
    createStubCompanies()
  }
  
  // Stub implementations - do nothing or return empty
  func getCompany(companyId: String) async throws -> Company { createStubCompanies()[0] }
  func createCompany(company: Company) async throws {}
  func updateCompany(company: Company) async throws {}
  func deleteCompany(companyId: String) async throws {}
  func updateBookmarkStatus(for company: Company, isBookmarked: Bool) async throws {}
  func getBookmarkedCompanies() async throws -> [Company] { [] }
  func uploadLogoImage(_ image: UIImage) async throws -> String { "" }
  func uploadHeaderImage(_ image: UIImage) async throws -> String { "" }
  func uploadPortfolioImages(_ images: [UIImage]) async throws -> [String] { [] }
}

func createStubEntrepreneurs() -> [Entrepreneur] {
  let entrepreneur1 = Entrepreneur(
    entrepId: "1",
    fullName: "Alice Johnson",
    profileUrl: "avatar.jpg",
    email: "test@email.com",
    bioDescr: "Tech entrepreneur",
    companyIds: []
  )
  
  let entrepreneur2 = Entrepreneur(
    entrepId: "2",
    fullName: "Bob Smith",
    profileUrl: "avatar.jpg",
    email: "test@email.com",
    bioDescr: "Green energy pioneer",
    companyIds: []
  )
  return [entrepreneur1, entrepreneur2]
}

func createStubCompanies() -> [Company] {
  let company1 = Company(
    companyId: "1",
    entrepId: "3",
    categoryIds: [],
    name: "Tech Innovators Inc",
    logoImg: "tech_innovators_logo.png",
    headerImg: "tech_innovators_header.png",
    aboutUs: "Tech Innovators is a US-based software development company specializing in providing businesses worldwide with custom technology solutions. We are a mobile and web-based application development company with over 2,800 skilled software developers.",
    dateFounded: "2010-01-15",
    portfolioImages: ["portfolio1.jpg", "portfolio2.jpg", "portfolio3.jpg"],
    address: "1930 Bank St",
    city: "Ottawa",
    phoneNum: "123-456-7890",
    email: "contact@techinnovators.com",
    workHours: "Mon-Fri 9am-5pm",
    services: ["Software Development", "Mobile App Development", "Web Development"],
    socialMedia: [:],
    businessModel: .online,
    website: "www.techinnovators.com",
    ownershipTypes: [.femaleOwned],
    isBookmarked: false
  )
  
  let company2 = Company(
    companyId: "2",
    entrepId: "4",
    categoryIds: [],
    name: "Green Energy Solutions",
    logoImg: "green_energy_logo.png",
    headerImg: "green_energy_header.png",
    aboutUs: "We work with you based on your software development objectives to bring you the most value and the quickest return on investment while defining tactics and a dedicated team to your project.",
    dateFounded: "2015-06-30",
    portfolioImages: ["portfolio1.jpg", "portfolio2.jpg", "portfolio3.jpg"],
    address: "456 Green Lane",
    city: "Austin",
    phoneNum: "987-654-3210",
    email: "info@greenenergy.com",
    workHours: "Mon-Fri 8am-6pm",
    services: ["Renewable Energy Consulting", "Solar Panel Installation", "Energy Audits"],
    socialMedia: [:],
    businessModel: .hybrid,
    website: "www.greenenergy.com",
    ownershipTypes: [.asianOwned],
    isBookmarked: false
  )
  
  let company3 = Company(
    companyId: "3",
    entrepId: "5",
    categoryIds: [],
    name: "Company name three",
    logoImg: "company_logo3",
    headerImg: "company_header3.png",
    aboutUs: "Our company was founded 10 years ago. Our software developers are organized in virtual divisions, carrying the domain experience and know-how within the industry to offer exceptional application development solutions.",
    dateFounded: "2006-10-13",
    portfolioImages: [],
    address: "123 Bank street",
    city: "New York",
    phoneNum: "123456",
    email: "test@gmail.com",
    workHours: "Mon 9 - 5, Tue 9 - 5, Wed 9 - 5, Thu 9 - 5, Fri 9 - 5",
    services: ["Custom Software Solutions", "IT Consulting", "Cloud Services"],
    socialMedia: [:],
    businessModel: .offline,
    website: "www.companythree.com",
    ownershipTypes: [.latinxOwned],
    isBookmarked: false
  )
  
  let company4 = Company(
    companyId: "4",
    entrepId: "4",
    categoryIds: [],
    name: "Company name four",
    logoImg: "company_logo4",
    headerImg: "company_header4.png",
    aboutUs: "We work with you based on your software development objectives to bring you the most value and the quickest return on investment while defining tactics and a dedicated team to your project.",
    dateFounded: "2006-10-13",
    portfolioImages: [],
    address: "123 Bank street",
    city: "Los Angeles",
    phoneNum: "123456",
    email: "test@gmail.com",
    workHours: "Mon-Fri 9 - 5",
    services: ["Project Management", "Business Analysis", "Quality Assurance"],
    socialMedia: [:],
    businessModel: .online,
    website: "www.companyfour.com",
    ownershipTypes: [.lgbtqOwned],
    isBookmarked: false
  )
  
  return [company1, company2, company3, company4]
}
