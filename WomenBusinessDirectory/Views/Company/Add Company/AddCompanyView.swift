//
//  AddCompanyView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/17/24.
//

import SwiftUI
import Foundation
import PhotosUI
import MapKit
import Combine

struct AddCompanyView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: AddCompanyViewModel
  let entrepreneur: Entrepreneur
  var editingCompany: Company?
  
  @State private var companyName = ""
  @State private var logoImage: UIImage?
  @State private var headerImage: UIImage?
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
  @State private var socialMediaLinks: [(platform: Company.SocialMedia, link: String)] = []
  @State private var selectedSocialMedia: Company.SocialMedia = .instagram
  @State private var socialMediaLinkInput: String = ""
  
  @State private var selectedCategoryIds: Set<String> = []
  @State private var isImagePickerPresented = false
  @State private var isHeaderImagePickerPresented = false
  @State private var isPortfolioPickerPresented = false
  @State private var currentPage = 0
  @State private var selectedOwnershipTypes: Set<Company.OwnershipType> = []
  @State private var workHoursType = Company.WorkingHoursType.standard
  @State private var customWorkHours = ""
  
  @StateObject private var addressCompleter = AddressCompleter()
  @State private var showAddressSuggestions = false
  @State private var showCitySuggestions = false
  
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
      _socialMediaInsta = State(initialValue: company.socialMedias.contains(.instagram) ? "instagram" : "")
      _socialMediaFacebook = State(initialValue: company.socialMedias.contains(.facebook) ? "facebook" : "")
      _selectedCategoryIds = State(initialValue: Set(company.categoryIds))
      _selectedOwnershipTypes = State(initialValue: Set(company.ownershipTypes))
      
      // Validate phone number during initialization
      _isValidPhone = State(initialValue: NSPredicate(format: "SELF MATCHES %@", canadianPhonePattern)
          .evaluate(with: company.phoneNum))
      
      // Initialize social media links from the company data
      var links: [(platform: Company.SocialMedia, link: String)] = []
      for platform in company.socialMedias {
          if let socialMedia = company.socialMedia,
             let link = socialMedia[platform] {
              links.append((platform: platform, link: link))
          } else {
              // If we have the platform but no link, add a default empty link
              links.append((platform: platform, link: ""))
          }
      }
      _socialMediaLinks = State(initialValue: links)
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM"
      if let date = formatter.date(from: company.dateFounded.prefix(7).description) {
        _dateFounded = State(initialValue: date)
      }
    } else {
      // For new company, pre-fill with entrepreneur's email
      _email = State(initialValue: entrepreneur.email ?? "")
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
                .fill(index == currentPage ? Color.yellow : Color.gray.opacity(0.3))
                .frame(width: 12, height: 12)
              Text(stepTitle(for: index))
                .font(.caption2)
                .foregroundColor(index == currentPage ? .yellow : .gray)
            }
            if index < 2 {
              Rectangle()
                .fill(index < currentPage ? Color.yellow : Color.gray.opacity(0.3))
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
                  viewModel.isSaving = true  // Show progress view
                  try await saveOrUpdateCompany()
                  viewModel.isSaving = false  // Hide progress view
              } catch {
                  viewModel.isSaving = false  // Hide progress view on error
                  print("Failed to save company: \(error)")
              }
            }
          }
        }) {
          HStack {
            Text(currentPage < 2 ? "Next" : (editingCompany != nil ? "Update" : "Save"))
              .fontWeight(.regular)
          }
          .frame(width: 100, height: 40)
          .foregroundColor(.yellow)
          .background(Color.white)
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.gray, lineWidth: 1)
          )
        }
        .disabled(!isFormValid)
        .padding(.horizontal)
        .padding(.bottom)
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $isImagePickerPresented) {
        ImagePicker(image: $logoImage)
      }
      .sheet(isPresented: $isHeaderImagePickerPresented) {
        ImagePicker(image: $headerImage)
      }
      .sheet(isPresented: $isPortfolioPickerPresented) {
        PortfolioImagePicker(images: $portfolioImages, maxSelection: 6)
      }
      .overlay {
        if viewModel.isSaving {
          Color.black.opacity(0.4)
            .ignoresSafeArea()
          VStack(spacing: 16) {
            ProgressView()
              .scaleEffect(1.5)
              .tint(.yellow)
            Text(editingCompany != nil ? "Updating company..." : "Saving company...")
              .font(.headline)
              .foregroundColor(.yellow)
          }
        }
      }
      .disabled(viewModel.isSaving)
    }
  }
  
  private var companyInfoSection: some View {
    CompanyInfoSection(
        companyName: $companyName,
        logoImage: $logoImage,
        headerImage: $headerImage,
        portfolioImages: $portfolioImages,
        dateFounded: $dateFounded,
        aboutUs: $aboutUs,
        selectedCategoryIds: $selectedCategoryIds,
        selectedOwnershipTypes: $selectedOwnershipTypes,
        isImagePickerPresented: $isImagePickerPresented,
        isHeaderImagePickerPresented: $isHeaderImagePickerPresented,
        isPortfolioPickerPresented: $isPortfolioPickerPresented,
        viewModel: viewModel
    )
  }
  
  private var categoriesSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Business Categories *")
        .font(.subheadline)
        .foregroundColor(.gray)
        .padding(.horizontal)
      
      Text("You can select several categories")
        .font(.caption)
        .foregroundColor(.gray)
        .padding(.horizontal)
      
      CategorySelectionGrid(selectedIds: $selectedCategoryIds)
    }
  }
  
  private var ownershipSection: some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text("Ownership Type")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("(Optional)")
                .font(.caption)
                .foregroundColor(.gray)
                .italic()
        }
        .padding(.horizontal)
      
        OwnershipTypeGrid(selectedTypes: $selectedOwnershipTypes)
    }
  }
  
  private var portfolioSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Portfolio")
        .font(.subheadline)
        .foregroundColor(.gray)
      
      Text("Adding portfolio images is recommended as they help showcase and promote your company's services. You can choose up to 6 images.")
        .font(.caption)
        .foregroundColor(.gray)
        .padding(.horizontal)
      
      Button(action: { isPortfolioPickerPresented = true }) {
        HStack {
          Image(systemName: "photo.stack.fill")
            .foregroundColor(.yellow)
          Text(portfolioImages.isEmpty ? "Add Portfolio Images" : "Add More Images")
            .foregroundColor(.yellow)
          Spacer()
          Text("\(portfolioImages.count)/6")
            .font(.caption)
            .foregroundColor(portfolioImages.count == 6 ? .red : .gray)
            .fontWeight(portfolioImages.count == 6 ? .bold : .regular)
        }
        .padding(8)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
      }
      .disabled(portfolioImages.count >= 6)
      
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
                      .foregroundColor(.yellow)
                      .background(Color.yellow.opacity(0.6))
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
    BusinessDetailsSection(
        workHoursType: $workHoursType,
        customWorkHours: $customWorkHours,
        services: $services,
        businessModel: $businessModel
    )
  }
  
  private var contactInfoSection: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 16) {
          Text("Contact Information")
            .font(.headline)
          
          Group {
            PhoneNumberField(phoneNum: $phoneNum, isValidPhone: $isValidPhone, editingCompany: editingCompany)
            
            VStack(alignment: .leading) {
                CustomTextField(title: "Address *", text: $address)
            }
            CityField(city: $city)
            
            VStack(alignment: .leading) {
                Text("Company Email *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("This can be different from your account email")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 4)
                TextField(entrepreneur.email ?? "", text: $email)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading) {
                Text("Website")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Website", text: $website)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
          }
          
          VStack(alignment: .leading, spacing: 12) {
            Text("Social Media")
              .font(.subheadline)
              .foregroundColor(.gray)
            
            Text("Add your social media profiles")
              .font(.caption)
              .foregroundColor(.gray)
              .padding(.bottom, 4)
            
            HStack(spacing: 10) {
              // Platform dropdown
              Menu {
                ForEach(Company.SocialMedia.allCases, id: \.self) { platform in
                  Button(platform.rawValue) {
                    selectedSocialMedia = platform
                  }
                }
              } label: {
                HStack {
                  Text(selectedSocialMedia.rawValue)
                    .foregroundColor(.primary)
                  Spacer()
                  Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                }
                .frame(width: 120)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
              }
              
              // Link text field
              TextField("Enter profile link", text: $socialMediaLinkInput)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
              
              // Add button
              Button(action: {
                if !socialMediaLinkInput.isEmpty {
                  socialMediaLinks.append((selectedSocialMedia, socialMediaLinkInput))
                  socialMediaLinkInput = ""
                }
              }) {
                Image(systemName: "plus.circle.fill")
                  .foregroundColor(.yellow)
                  .font(.title3)
              }
              .disabled(socialMediaLinkInput.isEmpty)
            }
            
            // Display added social media links
            if !socialMediaLinks.isEmpty {
              VStack(alignment: .leading, spacing: 8) {
                Text("Added Profiles:")
                  .font(.caption)
                  .foregroundColor(.gray)
                  .padding(.top, 4)
                
                ForEach(socialMediaLinks.indices, id: \.self) { index in
                  HStack {
                    // Platform icon in a circular background
                    ZStack {
                      Circle()
                        .fill(Color.yellow.opacity(0.1))
                        .frame(width: 28, height: 28)
                      
                      Image(systemName: socialMediaLinks[index].platform.icon)
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    }
                    
                    Text(socialMediaLinks[index].platform.rawValue)
                      .font(.subheadline)
                      .foregroundColor(.primary)
                    Spacer()
                    
                    Button(action: {
                      socialMediaLinks.remove(at: index)
                    }) {
                      Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    }
                  }
                  .padding(8)
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(8)
                }
              }
            }
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
        return !services.isEmpty // Services is required
    case 2: // Contact Info
        return !address.isEmpty && 
               !city.isEmpty &&
               !email.isEmpty &&
               (phoneNum.isEmpty || isValidPhone) // Phone is optional but must be valid if provided
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
        headerImage: headerImage,
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
        socialMediaLinks: socialMediaLinks,
        selectedCategoryIds: selectedCategoryIds,
        selectedOwnershipTypes: selectedOwnershipTypes
      )
    } else {
      try await viewModel.saveCompany(
        entrepreneur: entrepreneur,
        companyName: companyName,
        logoImage: logoImage,
        headerImage: headerImage,
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
        socialMediaLinks: socialMediaLinks,
        selectedCategoryIds: selectedCategoryIds,
        selectedOwnershipTypes: selectedOwnershipTypes
      )
    }
    dismiss()
  }
}

struct CompanyInfoSection: View {
    @Binding var companyName: String
    @Binding var logoImage: UIImage?
    @Binding var headerImage: UIImage?
    @Binding var portfolioImages: [UIImage]
    @Binding var dateFounded: Date
    @Binding var aboutUs: String
    @Binding var selectedCategoryIds: Set<String>
    @Binding var selectedOwnershipTypes: Set<Company.OwnershipType>
    @Binding var isImagePickerPresented: Bool
    @Binding var isHeaderImagePickerPresented: Bool
    @Binding var isPortfolioPickerPresented: Bool
    @ObservedObject var viewModel: AddCompanyViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Company Information")
                        .font(.headline)
                    
                    CustomTextField(title: "Company Name *", text: $companyName)
                    
                    // Images Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Images")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Logo Image
                        ImagePickerButton(
                            title: "Company Logo",
                            image: $logoImage,
                            isPresented: $isImagePickerPresented
                        )
                        
                        // Header Image
                        ImagePickerButton(
                            title: "Header Image",
                            image: $headerImage,
                            isPresented: $isHeaderImagePickerPresented
                        )
                        
                        // Portfolio Images
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adding portfolio images is recommended as they help showcase and promote your company's services.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: { isPortfolioPickerPresented = true }) {
                                HStack {
                                    Image(systemName: "photo.stack.fill")
                                        .foregroundColor(.yellow)
                                    Text(portfolioImages.isEmpty ? "Add Portfolio Images" : "Add More Images")
                                        .foregroundColor(.yellow)
                                    Spacer()
                                    Text("\(portfolioImages.count)/6")
                                        .font(.caption)
                                        .foregroundColor(portfolioImages.count == 6 ? .red : .gray)
                                        .fontWeight(portfolioImages.count == 6 ? .bold : .regular)
                                }
                                .padding(8)
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .disabled(portfolioImages.count >= 6)
                            
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
                                                            .foregroundColor(.yellow)
                                                            .background(Color.yellow.opacity(0.6))
                                                            .clipShape(Circle())
                                                    }
                                                    .padding(4),
                                                    alignment: .topTrailing
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Date Founded
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Founded")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $dateFounded, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                    }
                    
                    // About Us
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Us *")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $aboutUs)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Categories
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categories *")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        CategorySelectionGrid(selectedIds: $selectedCategoryIds)
                            .environmentObject(viewModel)
                    }
                    
                    // Ownership Types
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Ownership Type")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("(Optional)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .italic()
                        }
                        OwnershipTypeGrid(selectedTypes: $selectedOwnershipTypes)
                    }
                }
            }
            .padding()
        }
    }
}

struct ImagePickerButton: View {
    let title: String
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: { isPresented = true }) {
            HStack {
                Image(systemName: "photo")
                Text(image == nil ? "Add \(title)" : "Change \(title)")
                if image != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow.opacity(0.1))
            .foregroundColor(.yellow)
            .cornerRadius(8)
        }
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

struct PhoneNumberField: View {
    @Binding var phoneNum: String
    @Binding var isValidPhone: Bool
    let editingCompany: Company?
    private let canadianPhonePattern = #"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$"#
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField(title: "Phone Number", text: $phoneNum, placeholder: "123-456-7890")
            if !phoneNum.isEmpty && phoneNum != editingCompany?.phoneNum {
                Text(isValidPhone ? "Valid phone number" : "Please enter a valid Canadian phone number (e.g., 123-456-7890)")
                    .font(.caption)
                    .foregroundColor(isValidPhone ? .green : .red)
                    .padding(.top, 4)
            }
        }
        .onChange(of: phoneNum) { oldValue, newValue in
            formatAndValidatePhoneNumber(newValue)
        }
    }
    
    private func formatAndValidatePhoneNumber(_ value: String) {
        // Clean the phone number string
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleaned.count > 10 {
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

struct AddressField: View {
    @Binding var address: String
    @Binding var city: String
    @StateObject private var addressCompleter = AddressCompleter()
    @State private var showAddressSuggestions = false
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField(title: "Address *", text: $address)
                .onChange(of: address) {oldValue, newValue in
                    addressCompleter.searchAddress(newValue)
                    showAddressSuggestions = !newValue.isEmpty
                }
            
            if showAddressSuggestions && !addressCompleter.suggestions.isEmpty {
                SuggestionsList(suggestions: addressCompleter.suggestions) { suggestion in
                    address = suggestion.title
                    showAddressSuggestions = false
                    if let cityProvince = addressCompleter.extractCityAndProvince(from: suggestion) {
                        city = cityProvince
                    }
                }
            }
        }
        .onTapGesture {
            showAddressSuggestions = false
        }
    }
}

struct CityField: View {
    @Binding var city: String
    @StateObject private var addressCompleter = AddressCompleter()
    @State private var showCitySuggestions = false
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField(title: "City *", text: $city)
                .onChange(of: city) { oldValue, newValue in
                    addressCompleter.searchCity(newValue)
                    showCitySuggestions = !newValue.isEmpty
                }
            
            if showCitySuggestions && !addressCompleter.citySuggestions.isEmpty {
                SuggestionsList(suggestions: addressCompleter.citySuggestions) { suggestion in
                    city = suggestion
                    showCitySuggestions = false
                }
            }
        }
        .onTapGesture {
            showCitySuggestions = false
        }
    }
}

struct SuggestionsList<T>: View {
    let suggestions: [T]
    let onSelect: (T) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                    Button(action: { onSelect(suggestion) }) {
                        Text(String(describing: suggestion))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    Divider()
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

class AddressCompleter: NSObject, ObservableObject {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var citySuggestions: [String] = []
    private let completer = MKLocalSearchCompleter()
    
    @Published private var addressQuery = ""
    @Published private var cityQuery = ""
    
    private var searchTask: Task<Void, Never>?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468), // Center of Canada
            span: MKCoordinateSpan(latitudeDelta: 90, longitudeDelta: 140)
        )
        
        // Observe address changes
        Task {
            for await _ in $addressQuery.values {
                await debounceAddressSearch()
            }
        }
        
        // Observe city changes
        Task {
            for await _ in $cityQuery.values {
                await debounceCitySearch()
            }
        }
    }
    
    private func debounceAddressSearch() async {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                completer.resultTypes = .address
                completer.queryFragment = addressQuery + " Canada"
            }
        }
    }
    
    private func debounceCitySearch() async {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                completer.resultTypes = .query
                completer.queryFragment = cityQuery + " Canada"
            }
        }
    }
    
    func searchAddress(_ query: String) {
        addressQuery = query
    }
    
    func searchCity(_ query: String) {
        cityQuery = query
    }
    
    func extractCityAndProvince(from result: MKLocalSearchCompletion) -> String? {
        let components = result.title.components(separatedBy: ",")
        guard components.count >= 2 else { return nil }
        
        // Get the city and province components
        let cityComponent = components[0].trimmingCharacters(in: .whitespaces)
        let provinceComponent = components[1].trimmingCharacters(in: .whitespaces)
        
        // Check if it's a Canadian province
        let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
        let foundProvince = provinces.first { provinceComponent.contains($0) }
        
        guard let province = foundProvince else { return nil }
        return "\(cityComponent), \(province)"
    }
}

extension AddressCompleter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            if completer.resultTypes == .address {
                // Filter for Canadian addresses
                self.suggestions = completer.results.filter { result in
                    result.title.contains("Canada") || 
                    result.subtitle.contains("Canada")
                }
            } else {
                // Filter and format city suggestions
                let canadianCities = completer.results
                    .compactMap { extractCityAndProvince(from: $0) }
                    .filter { !$0.isEmpty }
                self.citySuggestions = Array(Set(canadianCities)) // Remove duplicates
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Address completion failed with error: \(error.localizedDescription)")
    }
}

struct BusinessDetailsSection: View {
    @Binding var workHoursType: Company.WorkingHoursType
    @Binding var customWorkHours: String
    @Binding var services: String
    @Binding var businessModel: Company.BusinessModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Business Details")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Working Hours")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(Company.WorkingHoursType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    workHoursType = type
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CustomTextField(title: "Services Offered *", text: $services, placeholder: "List your services")
                        
                        Text("Separate services with comma, e.g.: Web Design, Mobile Apps, UI/UX Design")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
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
}

struct CategorySelectionGrid: View {
    @Binding var selectedIds: Set<String>
    @EnvironmentObject private var viewModel: AddCompanyViewModel
    
    var body: some View {
        NavigationLink(destination: MultipleSelectionList(categories: viewModel.categories, selectedCategoryIds: $selectedIds)) {
            HStack {
                Text(selectedIds.isEmpty ? "Select Categories" : "\(selectedIds.count) Categories Selected")
                    .foregroundColor(selectedIds.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        
        if !selectedIds.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories.filter { selectedIds.contains($0.id) }, id: \.self) { category in
                        Text(category.name)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}

struct OwnershipTypeGrid: View {
    @Binding var selectedTypes: Set<Company.OwnershipType>
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(Company.OwnershipType.allCases, id: \.self) { type in
                Button(action: {
                    if selectedTypes.contains(type) {
                        selectedTypes.remove(type)
                    } else {
                        selectedTypes.insert(type)
                    }
                }) {
                    HStack {
                        Image(systemName: selectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedTypes.contains(type) ? .yellow : .gray)
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
    }
}

struct SocialMediaToggle: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.yellow)
                }
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
    }
}
    
#Preview {
  AddCompanyView(viewModel: AddCompanyViewModel(), entrepreneur: createStubEntrepreneurs()[0])
}
