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
  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: AddCompanyViewModel
  let entrepreneur: Entrepreneur
  var editingCompany: Company?
  
  @State private var companyName = ""
  @State private var logoImage: UIImage?
  @State private var portfolioImages: [UIImage] = []
  @State private var dateFounded = Date()
  @State private var aboutUs = ""
  @State private var workHours = ""
  @State private var services = ""
  @State private var businessModel = Company.BusinessModel.offline
  @State private var address = ""
  @State private var city = ""
  @State private var phoneNum = ""
  @State private var email = ""
  @State private var website = ""
  @State private var socialMediaInsta = ""
  @State private var socialMediaFacebook = ""
  
  @State private var selectedCategoryIds: Set<String> = []
  @State private var isImagePickerPresented = false
  @State private var isPortfolioPickerPresented = false
  @State private var currentPage = 0
  @State private var selectedOwnershipTypes: Set<Company.OwnershipType> = []
  
  init(viewModel: AddCompanyViewModel, entrepreneur: Entrepreneur, editingCompany: Company? = nil) {
    self._viewModel = StateObject(wrappedValue: viewModel)
    self.entrepreneur = entrepreneur
    self.editingCompany = editingCompany
    
    // Pre-fill form if editing
    if let company = editingCompany {
      _companyName = State(initialValue: company.name)
      _aboutUs = State(initialValue: company.aboutUs)
      _workHours = State(initialValue: company.workHours)
      _services = State(initialValue: company.services.joined(separator: ", "))
      _businessModel = State(initialValue: company.businessModel)
      _address = State(initialValue: company.address)
      _city = State(initialValue: company.city)
      _phoneNum = State(initialValue: company.phoneNum)
      _email = State(initialValue: company.email)
      _website = State(initialValue: company.website)
      _socialMediaInsta = State(initialValue: company.socialMediaInsta)
      _socialMediaFacebook = State(initialValue: company.socialMediaFacebook)
      _selectedCategoryIds = State(initialValue: Set(company.categoryIds))
      _selectedOwnershipTypes = State(initialValue: Set(company.ownershipTypes))
      
// Use the non-optional dateFounded directly
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: company.dateFounded) {
          _dateFounded = State(initialValue: date)
        }
     }
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        // Enhanced Step Indicator
        HStack(spacing: 15) {
          ForEach(0..<3) { index in
            VStack(spacing: 8) {
              Circle()
                .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 12, height: 12)
              Text(stepTitle(for: index))
                .font(.caption2)
                .foregroundColor(index == currentPage ? .blue : .gray)
            }
            if index < 2 {
              Rectangle()
                .fill(index < currentPage ? Color.blue : Color.gray.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: 50)
            }
          }
        }
        .padding(.top, 20)
        .padding(.horizontal)
        
        TabView(selection: $currentPage) {
          companyInfoSection
            .tag(0)
          
          detailsSection
            .tag(1)
          
          contactInfoSection
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        // Enhanced Navigation Button
        Button(action: {
          if currentPage < 2 {
            withAnimation {
              currentPage += 1
            }
          } else {
            saveCompany()
          }
        }) {
          HStack {
            Text(currentPage < 2 ? "Next" : "Save Company")
              .fontWeight(.semibold)
            Image(systemName: currentPage < 2 ? "arrow.right" : "checkmark")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(12)
          .shadow(radius: 2)
        }
        .padding(.horizontal)
        .padding(.bottom)
      }
      .navigationBarTitle(editingCompany != nil ? "Edit Company" : "Add Company", displayMode: .inline)
      .sheet(isPresented: $isImagePickerPresented) {
        ImagePicker(image: $logoImage)
      }
      .sheet(isPresented: $isPortfolioPickerPresented) {
        PortfolioImagePicker(images: $portfolioImages, maxSelection: 6)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(editingCompany != nil ? "Save" : "Add") {
            Task {
              do {
                if let editingCompany = editingCompany {
                  try await viewModel.updateCompany(
                    company: editingCompany,
                    companyName: companyName,
                    logoImage: logoImage,
                    portfolioImages: portfolioImages,
                    aboutUs: aboutUs,
                    dateFounded: dateFounded,
                    workHours: workHours,
                    services: services,
                    businessModel: businessModel,
                    address: address,
                    city: city,
                    phoneNum: phoneNum,
                    email: email,
                    website: website,
                    socialMediaInsta: socialMediaInsta,
                    socialMediaFacebook: socialMediaFacebook,
                    selectedCategoryIds: selectedCategoryIds,
                    selectedOwnershipTypes: selectedOwnershipTypes
                  )
                } else {
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
                    city: city,
                    phoneNum: phoneNum,
                    email: email,
                    website: website,
                    socialMediaInsta: socialMediaInsta,
                    socialMediaFacebook: socialMediaFacebook,
                    selectedCategoryIds: selectedCategoryIds,
                    selectedOwnershipTypes: selectedOwnershipTypes
                  )
                }
                dismiss()
              } catch {
                print("Failed to save company: \(error)")
              }
            }
          }
          .disabled(!isFormValid)
        }
      }
    }
  }
  
  private var companyInfoSection: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Company Name Field
        CustomTextField(title: "Company Name", text: $companyName)
          .padding(.horizontal)
        
        // Logo and About Section
        HStack(alignment: .top, spacing: 12) {
          // Logo Button
          Button(action: { isImagePickerPresented = true }) {
            Group {
              if let logoImage = logoImage {
                Image(uiImage: logoImage)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 80, height: 80)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              } else {
                VStack(spacing: 4) {
                  Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                  Text("Logo")
                    .font(.caption2)
                    .foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
              }
            }
          }
          .buttonStyle(PlainButtonStyle())
          
          // About Company Field
          VStack(alignment: .leading, spacing: 4) {
            Text("About Company")
              .font(.caption)
              .foregroundColor(.gray)
            TextEditor(text: $aboutUs)
              .frame(height: 80)
              .padding(4)
              .background(Color.gray.opacity(0.1))
              .cornerRadius(8)
          }
        }
        .padding(.horizontal)
        
        // Date Founded - Compact Style
        VStack(alignment: .leading, spacing: 4) {
          Text("Date Founded")
            .font(.caption)
            .foregroundColor(.gray)
          DatePicker("", selection: $dateFounded, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
        }
        .padding(.horizontal)
        
        Divider()
          .padding(.vertical, 8)
        
        categoriesSection
        ownershipSection
        portfolioSection
      }
      .padding(.vertical)
    }
  }
  
  private var categoriesSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Business Categories")
        .font(.headline)
        .padding(.horizontal)
      
      NavigationLink(destination: MultipleSelectionList(categories: viewModel.categories, selectedCategoryIds: $selectedCategoryIds)) {
        HStack {
          Text(selectedCategoryIds.isEmpty ? "Select Categories" : "\(selectedCategoryIds.count) Categories Selected")
            .foregroundColor(selectedCategoryIds.isEmpty ? .gray : .primary)
          Spacer()
          Image(systemName: "chevron.right")
            .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
      }
      
      if !selectedCategoryIds.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(viewModel.categories.filter { selectedCategoryIds.contains($0.id) }, id: \.self) { category in
              Text(category.name)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green1.opacity(0.2))
                .cornerRadius(6)
            }
          }
          .padding(.horizontal)
        }
      }
    }
  }
  
  private var ownershipSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Ownership Type")
        .font(.headline)
        .padding(.horizontal)
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 8) {
        ForEach(Company.OwnershipType.allCases, id: \.self) { type in
          Button(action: {
            if selectedOwnershipTypes.contains(type) {
              selectedOwnershipTypes.remove(type)
            } else {
              selectedOwnershipTypes.insert(type)
            }
          }) {
            HStack {
              Image(systemName: selectedOwnershipTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedOwnershipTypes.contains(type) ? .blue : .gray)
              Text(type.rawValue)
                .font(.caption)
                .foregroundColor(.primary)
              Spacer()
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
          }
        }
      }
      .padding(.horizontal)
    }
  }
  
  private var portfolioSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Portfolio")
        .font(.headline)
        .padding(.horizontal)
      
      Button(action: { isPortfolioPickerPresented = true }) {
        HStack {
          Image(systemName: "photo.stack.fill")
          Text(portfolioImages.isEmpty ? "Add Portfolio Images" : "Add More Images")
          Spacer()
          Text("\(portfolioImages.count)/6")
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
      }
      
      if !portfolioImages.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(portfolioImages.indices, id: \.self) { index in
              Image(uiImage: portfolioImages[index])
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                  Button(action: {
                    portfolioImages.remove(at: index)
                  }) {
                    Image(systemName: "xmark.circle.fill")
                      .foregroundColor(.white)
                      .background(Color.black.opacity(0.6))
                      .clipShape(Circle())
                  }
                  .padding(4),
                  alignment: .topTrailing
                )
            }
          }
          .padding(.horizontal)
        }
      }
    }
  }
  
  private var detailsSection: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 16) {
          Text("Business Details")
            .font(.headline)
          
          CustomTextField(title: "Working Hours", text: $workHours, placeholder: "e.g., Mon-Fri 9-5")
          CustomTextField(title: "Services Offered", text: $services, placeholder: "List your services")
          
          VStack(alignment: .leading, spacing: 8) {
            Text("Business Model")
              .font(.subheadline)
              .foregroundColor(.gray)
            Picker("", selection: $businessModel) {
              ForEach(Company.BusinessModel.allCases, id: \.self) { model in
                Text(model.rawValue.capitalized)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
          }
        }
      }
      .padding()
    }
  }
  
  private var contactInfoSection: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 16) {
          Text("Contact Information")
            .font(.headline)
          
          Group {
            CustomTextField(title: "Phone Number", text: $phoneNum)
            CustomTextField(title: "Address", text: $address)
            CustomTextField(title: "City", text: $city)
            CustomTextField(title: "Website", text: $website)
          }
          
          VStack(alignment: .leading, spacing: 8) {
            Text("Social Media")
              .font(.subheadline)
            CustomTextField(title: "Instagram", text: $socialMediaInsta, icon: "camera")
            CustomTextField(title: "Facebook", text: $socialMediaFacebook, icon: "person.2")
          }
        }
      }
      .padding()
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
            city: city,
            phoneNum: phoneNum,
            email: email,
            website: website,
            socialMediaInsta: socialMediaInsta,
            socialMediaFacebook: socialMediaFacebook,
            selectedCategoryIds: selectedCategoryIds,
            selectedOwnershipTypes: selectedOwnershipTypes
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
  
  private func stepTitle(for index: Int) -> String {
    switch index {
    case 0: return "Info"
    case 1: return "Details"
    case 2: return "Contact"
    default: return ""
    }
  }
  
  private var isFormValid: Bool {
    // Implement your validation logic here
    true
  }
}

struct CustomTextField: View {
  let title: String
  @Binding var text: String
  var placeholder: String = ""
  var icon: String? = nil
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.gray)
      
      HStack {
        if let icon = icon {
          Image(systemName: icon)
            .foregroundColor(.gray)
        }
        TextField(placeholder.isEmpty ? title : placeholder, text: $text)
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(12)
    }
    .padding(.horizontal)
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
            if selectedCategoryIds.contains(category.id) {
              selectedCategoryIds.remove(category.id)
            } else {
              selectedCategoryIds.insert(category.id)
            }
          }) {
            HStack {
              Text(category.name)
              Spacer()
              if selectedCategoryIds.contains(category.id) {
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
