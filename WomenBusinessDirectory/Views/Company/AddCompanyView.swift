//
//  AddCompanyView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/17/24.
//

import SwiftUI

struct AddCompanyView: View {
  @StateObject var viewModel: AddCompanyViewModel
  var entrepreneur: Entrepreneur
  
  @Environment(\.dismiss) var dismiss
  
  @State private var companyName = ""
  @State private var category: Category? = nil
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
  
  @State private var selectedCategoryIds: Set<String> = []
  
  var body: some View {
    NavigationView {
      VStack {
        Form {
          Section(header: Text("Company info")) {
            TextField("Name", text: $companyName)
            NavigationLink(destination: MultipleSelectionList(categories: viewModel.categories, selectedCategoryIds: $selectedCategoryIds)) {
                Text("Choose corresponding categories")
            }
            HStack {
              let selectedCategories = viewModel.categories.filter { selectedCategoryIds.contains($0.categoryId) }
              ForEach(selectedCategories, id: \.self) { category in
                Text(category.name)
                  .font(.caption2)
              }
              .padding(5)
              .background(Color.green1).opacity(0.5)
              .cornerRadius(10)
            } // HStack
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
                guard !selectedCategoryIds.isEmpty else {
                  print("No categories selected")
                  return
                }
                
                let newCompany = Company(companyId: "", entrepId: entrepreneur.entrepId, categoryIds: Array(selectedCategoryIds), name: companyName, logoImg: logoImg, aboutUs: aboutUs, dateFounded: dateFounded, address: address, phoneNum: phoneNum, email: email, workHours: workHours, directions: directions, socialMediaFacebook: socialMediaFacebook, socialMediaInsta: socialMediaInsta)
                
                try await viewModel.createCompany(company: newCompany)
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

struct MultipleSelectionList: View {
  var categories: [Category]
  @Binding var selectedCategoryIds: Set<String>
  
  var body: some View {
    let sortedCategories = categories.sorted(by: { $0.name < $1.name })
    
    List {
      ForEach(sortedCategories, id: \.self) { category in
        HStack {
          Button(action: {
            if selectedCategoryIds.contains(category.categoryId) {
              selectedCategoryIds.remove(category.categoryId)
            } else {
              selectedCategoryIds.insert(category.categoryId)
            }
          }) {
            HStack {
              Text(category.name)
              Spacer()
              if selectedCategoryIds.contains(category.categoryId) {
                Image(systemName: "checkmark")
              }
              
            }
            .buttonStyle(BorderlessButtonStyle())
            
          } // HStack
        }// ForEach
      }
    }
  }
}
    
#Preview {
  AddCompanyView(viewModel: AddCompanyViewModel(), entrepreneur: createStubEntrepreneurs()[0])
}
