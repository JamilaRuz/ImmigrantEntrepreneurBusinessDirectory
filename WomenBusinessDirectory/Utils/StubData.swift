//
//  StubData.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/30/24.
//

import Foundation
import SwiftData

func createStubEntrepreneurs() -> [Entrepreneur] {
  let entrepreneur1 = Entrepreneur(
    entrepId: "1",
    fullName: "Alice Johnson",
    email: "test@email.com",
    bioDescr: "Tech entrepreneur",
    companyIds: []
  )
  
  let entrepreneur2 = Entrepreneur(
    entrepId: "2",
    fullName: "Bob Smith",
    email: "test@email.com",
    bioDescr: "Green energy pioneer",
    companyIds: []
  )
  return [entrepreneur1, entrepreneur2]
}

func createStubCompanies() -> [Company] {
  let entrepreneur1 = Entrepreneur(
    entrepId: "3",
    fullName: "Alice Johnson",
    email: "test@email.com",
//    profileImage: "alice.jpg",
    bioDescr: "Tech entrepreneur",
    companyIds: []
  )
  
  let entrepreneur2 = Entrepreneur(
    entrepId: "4",
    fullName: "Bob Smith",
//    profileImage: "bob.jpg",
    email: "test@email.com",
    bioDescr: "Green energy pioneer",
    companyIds: []
  )

  let company1 = Company(
    companyId: "1",
    entrepId: "3",
    categoryIds: [], 
    name: "Tech Innovators Inc",
    logoImg: "tech_innovators_logo.png",
    aboutUs: "Tech Innovators is a US-based software development company specializing in providing businesses worldwide with custom technology solutions. We are a mobile and web-based application development company with over 2,800 skilled software developers.",
    dateFounded: "2010-01-15",
    address: "123 Tech Street, Silicon Valley, CA",
    phoneNum: "123-456-7890",
    email: "contact@techinnovators.com",
    workHours: "Mon-Fri 9am-5pm",
    directions: "Near Tech Park",
    socialMediaFacebook: "facebook link",
    socialMediaInsta: "Insta link"
  )
  
  let company2 = Company(
    companyId: "2",
    entrepId: "4",
    categoryIds: [],
    name: "Green Energy Solutions",
    logoImg: "green_energy_logo.png",
    aboutUs: "We work with you based on your software development objectives to bring you the most value and the quickest return on investment while defining tactics and a dedicated team to your project.",
    dateFounded: "2015-06-30",
    address: "456 Green Lane, Austin, TX",
    phoneNum: "987-654-3210",
    email: "info@greenenergy.com",
    workHours: "Mon-Fri 8am-6pm",
    directions: "Next to Solar Park",
    socialMediaFacebook: "facebook link",
    socialMediaInsta: "Insta link"
  )
  
  let company3 = Company(
    companyId: "4",
    entrepId: "5",
    categoryIds: [],
    name: "Company name three",
    logoImg: "comp_logo3", aboutUs: "Our company was fouded 10 years ago. Our software developers are organized in virtual divisions, carrying the domain experience and know-how within the industry to offer exceptional application development solutions.", dateFounded: "10/13/2006", address: "123 Bank street", phoneNum: "123456", email: "test@gmail.com", workHours: "Mon 9 - 5, Tue 9 - 5, Wed 9 - 5, Thu 9 - 5, Fri 9 - 5, ", directions: "Near the pharmacy",
    socialMediaFacebook: "facebook link",
    socialMediaInsta: "Insta link" )
  
  let company4 = Company(
    companyId: "2",
    entrepId: "4",
    categoryIds: [],
    name: "Company name four", logoImg: "comp_logo4", aboutUs: "We work with you based on your software development objectives to bring you the most value and the quickest return on investment while defining tactics and a dedicated team to your project.", dateFounded: "10/13/2006", address: "123 Bank street", phoneNum: "123456", email: "test@gmail.com", workHours: "Mon-Fri 9 - 5", directions: "Near the pharmacy", socialMediaFacebook: "facebook link", socialMediaInsta: "Insta link"
  )
  
  return [company1, company2, company3, company4]
}
