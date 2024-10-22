//
//  AddCompanyView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/17/24.
//

import SwiftUI
import Foundation
import PhotosUI

struct AddCompanyView: View {
  @StateObject var viewModel: AddCompanyViewModel
  var entrepreneur: Entrepreneur
  
  @Environment(\.dismiss) var dismiss
  
  @State private var companyName = ""
  @State private var logoImage: UIImage?
  @State private var portfolioImages: [UIImage] = []
  @State private var dateFounded = Date()
  @State private var aboutUs = ""
  @State private var workHours = ""
  @State private var services = ""
    @State private var businessModel = Company.BusinessModel.offline
  @State private var address = ""
  @State private var phoneNum = ""
  @State private var email = ""
  @State private var website = ""
  @State private var socialMediaInsta = ""
  @State private var socialMediaFacebook = ""
  
  @State private var selectedCategoryIds: Set<String> = []
  @State private var isImagePickerPresented = false
  @State private var isPortfolioPickerPresented = false
  @State private var currentPage = 0
  
  var body: some View {
    NavigationView {
      VStack {
        // Step Indicator
        HStack {
          ForEach(0..<3) { index in
            Circle()
              .fill(index == currentPage ? Color.blue : Color.gray)
              .frame(width: 10, height: 10)
          }
        }
        .padding(.top)
        
        TabView(selection: $currentPage) {
          companyInfoSection
            .tag(0)
          
          detailsSection
            .tag(1)
          
          contactInfoSection
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        Button(action: {
          if currentPage < 2 {
            currentPage += 1
          } else {
            saveCompany()
          }
        }) {
          Text(currentPage < 2 ? "Next" : "Save")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
      }
      .navigationBarTitle("Add Company", displayMode: .inline)
      .sheet(isPresented: $isImagePickerPresented) {
        ImagePicker(image: $logoImage)
      }
      .sheet(isPresented: $isPortfolioPickerPresented) {
        PortfolioImagePicker(images: $portfolioImages, maxSelection: 6)
      }
    }
  }
  
  private var companyInfoSection: some View {
    Form {
      Section(header: Text("Company Info")) {
        logoAndAboutUsView
        DatePicker("Date Founded", selection: $dateFounded, displayedComponents: .date)
        TextField("Name", text: $companyName)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        NavigationLink(destination: MultipleSelectionList(categories: viewModel.categories, selectedCategoryIds: $selectedCategoryIds)) {
          Text("Choose corresponding categories")
        }
        selectedCategoriesView
        portfolioImagesView
      }
    }
  }
  
  private var logoAndAboutUsView: some View {
    HStack(alignment: .top) {
      Button(action: { isImagePickerPresented = true }) {
        VStack {
          if let logoImage = logoImage {
            Image(uiImage: logoImage)
              .resizable()
              .scaledToFit()
              .frame(width: 100, height: 100)
              .border(Color.gray, width: 1)
          } else {
            VStack {
              Image(systemName: "camera")
                .font(.largeTitle)
              Text("Add Company Logo")
                .font(.caption)
            }
            .frame(width: 100, height: 100)
            .border(Color.gray, width: 1)
          }
        }
      }
      .buttonStyle(PlainButtonStyle())
      
      TextEditor(text: $aboutUs)
        .frame(height: 100)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
        .padding(.leading)
    }
  }
  
  private var portfolioImagesView: some View {
    VStack(alignment: .leading) {
      Button(action: { isPortfolioPickerPresented = true }) {
        HStack {
          Image(systemName: "photo.on.rectangle.angled")
          Text("Add Portfolio Images")
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
      }
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(portfolioImages, id: \.self) { image in
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .frame(width: 100, height: 100)
              .border(Color.gray, width: 1)
          }
        }
      }
    }
  }
  
  private var detailsSection: some View {
    Form {
      Section(header: Text("Details")) {
        TextField("Working Hours (e.g., Mon-Fri 9-5)", text: $workHours)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        TextField("Services (comma-separated)", text: $services)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Picker("Business Model", selection: $businessModel) {
            let businessModels = Company.BusinessModel.allCases
            
            ForEach(businessModels, id: \.self) { model in
            Text(model.rawValue.capitalized)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
      }
    }
  }
  
  private var contactInfoSection: some View {
    Form {
      Section(header: Text("Contact Info")) {
        TextField("Phone Number", text: $phoneNum)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        TextField("Address", text: $address)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        TextField("Website", text: $website)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        TextField("Instagram", text: $socialMediaInsta)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        TextField("Facebook", text: $socialMediaFacebook)
          .textFieldStyle(RoundedBorderTextFieldStyle())
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
  
  private func saveCompany() {
    Task {
      do {
        try await viewModel.saveCompany(
            entrepreneur: entrepreneur,
            companyName: companyName,
            logoImage: logoImage,
            portfolioImages: portfolioImages,
            aboutUs: aboutUs,
            dateFounded: dateFounded,
            workHours: workHours,
            services: services,
            businessModel: businessModel,
            address: address,
            phoneNum: phoneNum,
            email: email,
            website: website,
            socialMediaInsta: socialMediaInsta,
            socialMediaFacebook: socialMediaFacebook,
            selectedCategoryIds: selectedCategoryIds
        )
        dismiss()
      } catch {
        print("Failed to save company: \(error)")
      }
    }
  }
  
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
          }
        }
      }
    }
  }
}
    
#Preview {
  AddCompanyView(viewModel: AddCompanyViewModel(), entrepreneur: createStubEntrepreneurs()[0])
}
