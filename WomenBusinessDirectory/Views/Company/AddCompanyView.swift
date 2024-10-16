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
  @State private var logoImage: UIImage?
  @State private var dateFounded = Date()
  @State private var aboutUs = ""
  @State private var workHours = ""
  @State private var services = ""
  @State private var businessModel = BusinessModel.offline
  @State private var address = ""
  @State private var phoneNum = ""
  @State private var email = ""
  @State private var website = ""
  @State private var socialMediaInsta = ""
  @State private var socialMediaFacebook = ""
  
  @State private var selectedCategoryIds: Set<String> = []
  @State private var isImagePickerPresented = false
  
  enum BusinessModel: String, CaseIterable {
    case online, offline, hybrid
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Company Info")) {
          logoButton
          DatePicker("Date Founded", selection: $dateFounded, displayedComponents: .date)
          TextField("Name", text: $companyName)
          NavigationLink(destination: MultipleSelectionList(categories: viewModel.categories, selectedCategoryIds: $selectedCategoryIds)) {
            Text("Choose corresponding categories")
          }
          selectedCategoriesView
        }
        
        Section(header: Text("Details")) {
          TextEditor(text: $aboutUs)
            .frame(height: 100)
          TextField("Working Hours (e.g., Mon-Fri 9-5)", text: $workHours)
          TextField("Services (comma-separated)", text: $services)
          Picker("Business Model", selection: $businessModel) {
            ForEach(BusinessModel.allCases, id: \.self) { model in
              Text(model.rawValue.capitalized)
            }
          }
        }
        
        Section(header: Text("Contact Info")) {
          TextField("Phone Number", text: $phoneNum)
          TextField("Address", text: $address)
          TextField("Website", text: $website)
          TextField("Instagram", text: $socialMediaInsta)
          TextField("Facebook", text: $socialMediaFacebook)
        }
      }
      .navigationBarTitle("Add Company", displayMode: .inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
//            saveCompany()
          }
        }
      }
      .sheet(isPresented: $isImagePickerPresented) {
        ImagePicker(image: $logoImage)
      }
    }
  }
  
  private var logoButton: some View {
    HStack {
      Button(action: { isImagePickerPresented = true }) {
        Text("Browse Logo")
      }
      if let logoImage = logoImage {
        Image(uiImage: logoImage)
          .resizable()
          .scaledToFit()
          .frame(height: 50)
      } else {
        Image(systemName: "photo")
          .frame(width: 50, height: 50)
          .background(Color.gray.opacity(0.2))
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
  }
  
  private var selectedCategoriesView: some View {
    let selectedCategories = viewModel.categories.filter { selectedCategoryIds.contains($0.categoryId) }
    return ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        ForEach(selectedCategories, id: \.self) { category in
          Text(category.name)
            .font(.caption2)
            .padding(5)
            .background(Color.green1.opacity(0.5))
            .cornerRadius(10)
        }
      }
    }
  }
  
//  private func saveCompany() {
//    Task {
//      do {
//        guard !selectedCategoryIds.isEmpty else {
//          print("No categories selected")
//          return
//        }
//        
//        var logoUrl = ""
//        if let logoImage = logoImage {
//          // Assuming you have a method in your viewModel to upload images
//          logoUrl = try await viewModel.uploadCompanyLogo(logoImage)
//        }
//        
//        let newCompany = Company(
//          companyId: "",
//          entrepId: entrepreneur.entrepId,
//          categoryIds: Array(selectedCategoryIds),
//          name: companyName,
//          logoImg: logoUrl,
//          aboutUs: aboutUs,
//          dateFounded: formatDate(dateFounded),
//          address: address,
//          phoneNum: phoneNum,
//          email: "", // You might want to remove this if it's not used
//          workHours: workHours,
//          socialMediaFacebook: socialMediaFacebook,
//          socialMediaInsta: socialMediaInsta,
//          website: website,
//          services: services.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
//          businessModel: businessModel.rawValue
//        )
//        
//        try await viewModel.createCompany(company: newCompany)
//        dismiss()
//      } catch {
//        print("Failed to create company: \(error)")
//      }
//    }
//  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
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
