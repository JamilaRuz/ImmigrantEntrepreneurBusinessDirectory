//
//  StubData.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/30/24.
//

import Foundation
import SwiftData

@MainActor func createPreviewModelContainer() -> ModelContainer {
  let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
  let container: ModelContainer
  
  do {
    container = try ModelContainer(for: Company.self, configurations: modelConfiguration)
    
    let context = container.mainContext
    
    let companies = createStubCompanies()
    let entrepreneurs = createStubEntrepreneurs()
    
    for company in companies {
      context.insert(company)
    }
    
    for entrepreneur in entrepreneurs {
      context.insert(entrepreneur)
    }

    let fetchCompanies = FetchDescriptor<Company>(sortBy: [SortDescriptor(\Company.name, order: .forward)])
    let companiesFromDb = try! context.fetch(fetchCompanies)
    
    let fetchEntrepreneurs = FetchDescriptor<Entrepreneur>(sortBy: [SortDescriptor(\Entrepreneur.fullName, order: .forward)])
    let entrepreneursFromDb = try! context.fetch(fetchEntrepreneurs)
    
    companiesFromDb[0].entrepreneur = entrepreneursFromDb[0]
    companiesFromDb[1].entrepreneur = entrepreneursFromDb[1]
    
    try context.save()
  } catch {
    fatalError("Failed to load preview container: \(error)")
  }
  
  return container
}

func createStubEntrepreneurs() -> [Entrepreneur] {
  let entrepreneur1 = Entrepreneur(
    fullName: "Alice Johnson",
//    profileImage: "alice.jpg",
    bioDescr: "Tech entrepreneur",
    companies: []
  )
  
  let entrepreneur2 = Entrepreneur(
    fullName: "Bob Smith",
//    profileImage: "bob.jpg",
    bioDescr: "Green energy pioneer",
    companies: []
  )
  return [entrepreneur1, entrepreneur2]
}

func createStubCompanies() -> [Company] {
  let entrepreneur1 = Entrepreneur(
    fullName: "Alice Johnson",
//    profileImage: "alice.jpg",
    bioDescr: "Tech entrepreneur",
    companies: []
  )
  
  let entrepreneur2 = Entrepreneur(
    fullName: "Bob Smith",
//    profileImage: "bob.jpg",
    bioDescr: "Green energy pioneer",
    companies: []
  )

  let company1 = Company(
    name: "Tech Innovators Inc",
    logoImg: "tech_innovators_logo.png",
    aboutUs: "Innovating tech solutions for the modern world.",
    dateFounded: "2010-01-15",
    address: "123 Tech Street, Silicon Valley, CA",
    phoneNum: "123-456-7890",
    email: "contact@techinnovators.com",
    workHours: "Mon-Fri 9am-5pm",
    directions: "Near Tech Park",
    category: Category(name: "technology", image: "technology"),
    socialMediaFacebook: "facebook link",
    socialMediaInsta: "Insta link",
    entrepreneur: entrepreneur1
  )
  
  let company2 = Company(
    name: "Green Energy Solutions",
    logoImg: "green_energy_logo.png",
    aboutUs: "Providing sustainable energy solutions.",
    dateFounded: "2015-06-30",
    address: "456 Green Lane, Austin, TX",
    phoneNum: "987-654-3210",
    email: "info@greenenergy.com",
    workHours: "Mon-Fri 8am-6pm",
    directions: "Next to Solar Park",
    category: Category(name: "health", image: "health"),
    socialMediaFacebook: "facebook link",
    socialMediaInsta: "Insta link",
    entrepreneur: entrepreneur2
  )
  
  let company3 = Company(
    name: "Company name three",
    logoImg: "comp_logo3", aboutUs: "Our company was fouded 10 years ago. It mainly focuses on software development. Our....", dateFounded: "10/13/2006", address: "123 Bank street", phoneNum: "123456", email: "test@gmail.com", workHours: "Mon 9 - 5, Tue 9 - 5, Wed 9 - 5, Thu 9 - 5, Fri 9 - 5, ", directions: "Near the pharmacy", category: Category(name: "Beauty", image: "health"), socialMediaFacebook: "facebook link", socialMediaInsta: "Insta link", entrepreneur: entrepreneur1
  )
  
  let company4 = Company(name: "Company name four", logoImg: "comp_logo4", aboutUs: "Our company was fouded 10 years ago. It mainly focuses on software development. Our....", dateFounded: "10/13/2006", address: "123 Bank street", phoneNum: "123456", email: "test@gmail.com", workHours: "Mon-Fri 9 - 5", directions: "Near the pharmacy", category: Category(name: "Beauty", image: "health"), socialMediaFacebook: "facebook link", socialMediaInsta: "Insta link", entrepreneur: entrepreneur2
  )
  
  return [company1, company2, company3, company4]
}
