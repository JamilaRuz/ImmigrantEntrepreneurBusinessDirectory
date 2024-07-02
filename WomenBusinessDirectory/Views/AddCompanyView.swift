//
//  AddCompanyView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/17/24.
//

import SwiftUI

struct AddCompanyView: View {
  @Environment(\.dismiss) var dismiss
  
  var entrepreneur: Entrepreneur

  @State private var companyName = ""

//  need to create picker
//  @State private var category: Category

  @State private var logoImg = ""
  @State private var dateFounded = ""
  @State private var aboutUs = ""
  @State private var workHours = ""
  
  @State private var address = ""
  @State private var directions = ""
  @State private var phoneNum = ""
  @State private var email = ""
  @State private var socialMediaFacebook = ""
  @State private var socialMediaInsta = ""
  
  var body: some View {
    NavigationView {
      VStack {
        Form {
          Section(header: Text("Company info")) {
            TextField("Name", text: $companyName)
//            Picker("Category", selection: $category) {
//              ForEach(categories, id: \.self) {
//                Text($0.name)
//              }
//            }
            TextField("Founded date", text: $dateFounded)
            TextField("About us", text: $aboutUs)
            TextField("Work hours", text: $workHours)
          }
          Section(header: Text("Company contact info")) {
            TextField("Phone number", text: $phoneNum)
            TextField("Email", text: $email)
            TextField("Address", text: $address)
            TextField("Facebook", text: $socialMediaFacebook)
            TextField("Instagram", text: $socialMediaInsta)
          }
        }
      }
      .navigationBarTitle("Add Company")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            Task {
              do {
                let categoryIds = [String]() // TODO get it from state
                
                let newCompany = Company(companyId: "", entrepId: entrepreneur.entrepId, categoryIds: categoryIds, name: companyName, logoImg: logoImg, aboutUs: aboutUs, dateFounded: dateFounded, address: address, phoneNum: phoneNum, email: email, workHours: workHours, directions: directions, socialMediaFacebook: socialMediaFacebook, socialMediaInsta: socialMediaInsta)
                
                try await CompanyManager.shared.createCompany(company: newCompany)
                try await EntrepreneurManager.shared.addCompany(company: newCompany)
                dismiss()
                return
              } catch {
                print("Failed to create company: \(error)")
              }
            }
          }
        } // toolbar
      }
    }
  }
}
  
//#Preview {
//  AddCompanyView()
//    .environment(\.modelContext, createPreviewModelContainer().mainContext)
//}
