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
  @State private var workHoursType = Company.WorkingHoursType.standard
  @State private var customWorkHours = ""
  
  private let canadianPhonePattern = #"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$"#
  @State private var isValidPhone = false
  
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
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM"
      if let date = formatter.date(from: company.dateFounded.prefix(7).description) {
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
            Task {
              do {
                  try await saveOrUpdateCompany()
              } catch {
                print("Failed to save company: \(error)")
              }
            }
          }
        }) {
          HStack {
            Text(currentPage < 2 ? "Next" : (editingCompany != nil ? "Save Changes" : "Save Company"))
              .fontWeight(.semibold)
            Image(systemName: currentPage < 2 ? "arrow.right" : "checkmark")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(isFormValid ? Color.blue : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(12)
          .shadow(radius: 2)
        }
        .disabled(!isFormValid)
        .padding(.horizontal)
        .padding(.bottom)
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $isImagePickerPresented) {
        ImagePicker(image: $logoImage)
      }
      .sheet(isPresented: $isPortfolioPickerPresented) {
        PortfolioImagePicker(images: $portfolioImages, maxSelection: 6)
      }
    }
  }
  
  private var companyInfoSection: some View {
    ScrollView {
      VStack(spacing: 16) {
        Text("Add your company information")
          .font(.headline)
          .foregroundColor(.gray)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
        
        Text("* Required fields")
          .font(.caption)
          .foregroundColor(.gray)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
        
        // Company Name Field
        CustomTextField(title: "Company Name *", text: $companyName)
          .padding(.horizontal)
        
        // Logo and Date Founded Row
        HStack(alignment: .top, spacing: 12) {
          // Logo Button
          VStack(alignment: .leading, spacing: 4) {
            Text("Logo *")
              .font(.subheadline)
              .foregroundColor(.gray)
            
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
                    Text("Upload")
                      .font(.caption2)
                      .foregroundColor(.gray)
                  }
                  .frame(width: 80, height: 80)
                  .background(Color.white)
                  .overlay(
                    RoundedRectangle(cornerRadius: 8)
                      .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                  )
                }
              }
            }
            .buttonStyle(PlainButtonStyle())
          }
          
          // Date Founded
          VStack(alignment: .leading, spacing: 4) {
            Text("Date Founded")
              .font(.subheadline)
              .foregroundColor(.gray)
            
            DatePicker("", selection: $dateFounded, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .environment(\.calendar, Calendar(identifier: .gregorian))
          }
        }
        .padding(.horizontal)
        
        // About Company Field
        VStack(alignment: .leading, spacing: 4) {
          Text("About Company *")
            .font(.subheadline)
            .foregroundColor(.gray)
          
          ZStack(alignment: .bottomLeading) {
            TextEditor(text: $aboutUs)
              .frame(height: 80)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.white)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray.opacity(0.3), lineWidth: 1)
              )
            
            Text("\(aboutUs.count)/4000")
              .font(.caption)
              .foregroundColor(.gray)
              .padding(8)
          }
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
      Text("Business Categories *")
        .font(.subheadline)
        .foregroundColor(.gray)
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
        .font(.subheadline)
        .foregroundColor(.gray)
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
        .font(.subheadline)
        .foregroundColor(.gray)
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
          
          // Working Hours Section
          VStack(alignment: .leading, spacing: 4) {
            Text("Working Hours")
              .font(.subheadline)
              .foregroundColor(.gray)
            
            Menu {
              ForEach(Company.WorkingHoursType.allCases, id: \.self) { type in
                Button(action: {
                  workHoursType = type
                }) {
                  HStack {
                    Text(type.rawValue)
                    if workHoursType == type {
                      Image(systemName: "checkmark")
                    }
                  }
                }
              }
            } label: {
              HStack {
                Text(workHoursType.rawValue)
                  .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                  .foregroundColor(.gray)
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
              .padding(.horizontal, 12)
              .background(Color.white)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray.opacity(0.3), lineWidth: 1)
              )
            }
            
            if workHoursType == .custom {
              TextField("Enter custom working hours", text: $customWorkHours)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
          }
          
          CustomTextField(title: "Services Offered *", text: $services, placeholder: "List your services")
          
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
            VStack(alignment: .leading) {
              CustomTextField(title: "Phone Number", text: $phoneNum, placeholder: "123-456-7890")
              if !phoneNum.isEmpty {
                Text(isValidPhone ? "Valid phone number" : "Please enter a valid Canadian phone number (e.g., 123-456-7890)")
                  .font(.caption)
                  .foregroundColor(isValidPhone ? .green : .red)
                  .padding(.top, 4)
              }
            }
            .onChange(of: phoneNum) { newValue in
              // Clean the phone number string
              let cleaned = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
              if cleaned.count > 10 {
                  // Trim to 10 digits if more are entered
                  phoneNum = String(cleaned.prefix(10))
              }
              
              // Format the phone number as user types
              if cleaned.count == 10 {
                  phoneNum = format(phoneNumber: cleaned)
              }
              
              // Validate the phone number
              isValidPhone = NSPredicate(format: "SELF MATCHES %@", canadianPhonePattern)
                  .evaluate(with: phoneNum)
            }
            
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
  
  private func formatDateForDisplay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: date)
  }
  
  private func formatDateForStorage(_ date: Date) -> String {
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
    switch currentPage {
    case 0: // Company Info
        return !companyName.isEmpty && 
               !selectedCategoryIds.isEmpty && 
               !aboutUs.isEmpty
    case 1: // Business Details
        return true // All fields in this section are optional
    case 2: // Contact Info
        return isValidPhone && 
               !address.isEmpty && 
               !city.isEmpty
    default:
        return false
    }
  }
  
  private var workHoursValue: String {
    switch workHoursType {
    case .custom:
      return customWorkHours
    default:
      return workHoursType.rawValue
    }
  }
  
  private func saveOrUpdateCompany() async throws {
    if let editingCompany = editingCompany {
      try await viewModel.updateCompany(
        company: editingCompany,
        companyName: companyName,
        logoImage: logoImage,
        portfolioImages: portfolioImages,
        aboutUs: aboutUs,
        dateFounded: dateFounded,
        workHours: workHoursValue,
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
        workHours: workHoursValue,
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
  }
  
  // Add helper function for phone number formatting
  private func format(phoneNumber: String) -> String {
      let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "")
      let mask = "XXX-XXX-XXXX"
      var result = ""
      var index = cleaned.startIndex
      for ch in mask where index < cleaned.endIndex {
          if ch == "X" {
              result.append(cleaned[index])
              index = cleaned.index(after: index)
          } else {
              result.append(ch)
          }
      }
      return result
  }
}

struct CustomTextField: View {
  let title: String
  @Binding var text: String
  var placeholder: String = ""
  var icon: String? = nil
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
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
      .padding(.vertical, 8)
      .padding(.horizontal, 12)
      .background(Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray.opacity(0.3), lineWidth: 1)
      )
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
