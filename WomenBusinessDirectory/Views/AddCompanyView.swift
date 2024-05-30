//
//  AddCompanyView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/17/24.
//

import SwiftUI
import SwiftData

struct AddCompanyView: View {
  @Environment(\.modelContext) var modelContext
  
  @State private var entrepreneurImage = ""
  @State private var entrepreneurFirstName = ""
  @State private var entrepreneurLastName = ""
  @State private var bioDescription = ""
  
  @State private var companyName = ""
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
    VStack {
      Form {
        Section(header: Text("Entrepreneur info")) {
          TextField("Name", text: $entrepreneurFirstName)
          TextField("Last name", text: $entrepreneurLastName)
          TextField("Bio", text: $bioDescription)
        }
        Section(header: Text("Company info")) {
          TextField("Name", text: $companyName)
          //          Choose a category from dropdown
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
    .toolbar {
      Button("Save") {
        
      }
    }
  }
}

#Preview {
  AddCompanyView()
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
