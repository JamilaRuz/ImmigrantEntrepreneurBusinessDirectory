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
  @Environment(\.colorScheme) private var colorScheme
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
  @State private var socialMediaLinks: [(platform: Company.SocialMedia, link: String)] = []
  @State private var selectedSocialMedia: Company.SocialMedia = .instagram
  @State private var socialMediaLinkInput: String = ""
  @State private var socialMediaLinkError: String? = nil
  @State private var socialMediaPlaceholder: String = "instagram.com/"
  
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
  
  private let canadianPhonePattern = #"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$"#
  @State private var isValidPhone = false
  
  @FocusState private var isAddressFieldFocused: Bool
  
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
      _selectedCategoryIds = State(initialValue: Set(company.categoryIds))
      _selectedOwnershipTypes = State(initialValue: Set(company.ownershipTypes))
      
      // Validate phone number during initialization
      _isValidPhone = State(initialValue: NSPredicate(format: "SELF MATCHES %@", canadianPhonePattern)
          .evaluate(with: company.phoneNum))
      
      // Initialize social media links from the company data
      var links: [(platform: Company.SocialMedia, link: String)] = []
      for platform in company.socialMediaPlatforms {
          if let socialMedia = company.socialMedias,
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
          .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray, lineWidth: 1)
          )
        }
        .disabled(!isFormValid)
        .padding(.horizontal)
        .padding(.bottom)
      }
      .navigationTitle(editingCompany != nil ? "Edit Business/Service" : "Add Business/Service")
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
            Text(editingCompany != nil ? "Updating..." : "Saving...")
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
            
            AddressField(address: $address, city: $city)
            
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
                    .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading) {
                Text("Website")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 0) {
                    Text("https://")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    TextField("website.com", text: $website)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
                .padding(.vertical, 8)
                .padding(.trailing, 12)
                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
          }
          
          VStack(alignment: .leading, spacing: 12) {
            Text("Social Media of the company")
              .font(.subheadline)
              .foregroundColor(.gray)
            
            Text("Add your social media profiles according to the shown prompt format")
              .font(.caption)
              .foregroundColor(.gray)
              .padding(.bottom, 4)
            
            HStack(spacing: 10) {
              // Platform dropdown
              Menu {
                ForEach(Company.SocialMedia.allCases, id: \.self) { platform in
                  Button(platform.rawValue) {
                    selectedSocialMedia = platform
                    socialMediaLinkError = nil // Clear error when changing platform
                    socialMediaLinkInput = "" // Clear input when changing platform
                    
                    // Update placeholder based on selected platform
                    switch platform {
                    case .instagram:
                      socialMediaPlaceholder = "username (without @)"
                    case .facebook:
                      socialMediaPlaceholder = "username or page-name"
                    case .twitter:
                      socialMediaPlaceholder = "username (without @)"
                    case .linkedin:
                      socialMediaPlaceholder = "in/username or company/name"
                    case .youtube:
                      socialMediaPlaceholder = "channel/ID or c/name"
                    case .other:
                      socialMediaPlaceholder = "full URL (with domain name)"
                    }
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
                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
              }
              
              // Link text field with prefix
              HStack(spacing: 0) {
                // Show the appropriate prefix based on platform type
                switch selectedSocialMedia {
                case .instagram:
                  Text("instagram.com/")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                case .facebook:
                  Text("facebook.com/")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                case .twitter:
                  Text("twitter.com/")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                case .linkedin:
                  Text("linkedin.com/")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                case .youtube:
                  Text("youtube.com/")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                case .other:
                  Text("https://")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                }
                
                TextField(socialMediaPlaceholder, text: $socialMediaLinkInput)
                  .autocorrectionDisabled(true)
                  .textInputAutocapitalization(.never)
                  .keyboardType(.URL)
              }
              .padding(.vertical, 8)
              .padding(.trailing, 12)
              .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(socialMediaLinkError != nil ? Color.red : (colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)), lineWidth: 1)
              )
              .onChange(of: socialMediaLinkInput) { _, _ in
                socialMediaLinkError = nil // Clear error when typing
              }
              
              // Add button
              Button(action: {
                if validateSocialMediaLink(platform: selectedSocialMedia, link: socialMediaLinkInput) {
                  let formattedLink = formatSocialMediaLink(platform: selectedSocialMedia, link: socialMediaLinkInput)
                  socialMediaLinks.append((selectedSocialMedia, formattedLink))
                  socialMediaLinkInput = ""
                  socialMediaLinkError = nil
                }
              }) {
                Image(systemName: "plus.circle.fill")
                  .foregroundColor(.yellow)
                  .font(.title3)
              }
              .disabled(socialMediaLinkInput.isEmpty)
            }
            
            // Display error if any
            if let error = socialMediaLinkError {
              Text(error)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 4)
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
    case 0: return "Basic"
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
    // Format website URL to ensure it has https:// prefix
    let formattedWebsite = formatWebsiteURL(website)
    
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
        website: formattedWebsite,
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
        website: formattedWebsite,
        socialMediaLinks: socialMediaLinks,
        selectedCategoryIds: selectedCategoryIds,
        selectedOwnershipTypes: selectedOwnershipTypes
      )
    }
    dismiss()
  }
  
  // Helper function to format website URL
  private func formatWebsiteURL(_ url: String) -> String {
    let formattedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // If it's empty, return empty string
    if formattedURL.isEmpty {
        return ""
    }
    
    // If it already has http:// or https://, keep it as is
    if formattedURL.lowercased().hasPrefix("http://") || formattedURL.lowercased().hasPrefix("https://") {
        return formattedURL
    }
    
    // Otherwise, add https:// prefix
    return "https://" + formattedURL
  }
  
  // Update the validation function to handle just usernames/handles
  private func validateSocialMediaLink(platform: Company.SocialMedia, link: String) -> Bool {
    // If link is empty, it's not valid
    if link.isEmpty {
      socialMediaLinkError = "Please enter a link"
      return false
    }
    
    // Clean the link for validation
    let cleanLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Simplified validation based on platform
    switch platform {
    case .instagram:
      // For Instagram, just validate the username format
      // Username should not contain spaces or special characters except _ and .
      if cleanLink.contains(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "." }) {
        socialMediaLinkError = "Instagram username contains invalid characters"
        return false
      }
      return true
      
    case .facebook:
      // For Facebook, anything without spaces is probably valid
      if cleanLink.contains(" ") {
        socialMediaLinkError = "Facebook username should not contain spaces"
        return false
      }
      return true
      
    case .twitter:
      // For Twitter, just check for a valid username without @
      if cleanLink.hasPrefix("@") {
        socialMediaLinkError = "Don't include the @ symbol"
        return false
      }
      if cleanLink.contains(where: { !$0.isLetter && !$0.isNumber && $0 != "_" }) {
        socialMediaLinkError = "Twitter username contains invalid characters"
        return false
      }
      return true
      
    case .linkedin:
      // LinkedIn can have "in/username" or "company/name" formats
      if !cleanLink.contains("/") && !cleanLink.lowercased().hasPrefix("in/") && !cleanLink.lowercased().hasPrefix("company/") {
        socialMediaLinkError = "Include 'in/' for profiles or 'company/' for pages"
        return false
      }
      return true
      
    case .youtube:
      // YouTube can have several formats, so be lenient here
      return true
      
    case .other:
      // For other social media platforms, just make sure it contains a domain
      if !cleanLink.contains(".") {
        socialMediaLinkError = "Please enter a valid URL with a domain name"
        return false
      }
      return true
    }
  }
  
  // Update the formatting function to add appropriate prefixes based on platform
  private func formatSocialMediaLink(platform: Company.SocialMedia, link: String) -> String {
    let formattedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Add the appropriate domain prefix based on platform
    switch platform {
    case .instagram:
      return "https://instagram.com/" + formattedLink
    case .facebook:
      return "https://facebook.com/" + formattedLink
    case .twitter:
      return "https://twitter.com/" + formattedLink
    case .linkedin:
      // If it already has the "in/" or "company/" prefix, don't duplicate it
      if formattedLink.lowercased().hasPrefix("in/") || formattedLink.lowercased().hasPrefix("company/") {
        return "https://linkedin.com/" + formattedLink
      } else {
        // Default to "in/" prefix if none provided
        return "https://linkedin.com/in/" + formattedLink
      }
    case .youtube:
      // If it already has channel/ or c/ prefix, don't duplicate it
      if formattedLink.lowercased().hasPrefix("channel/") || formattedLink.lowercased().hasPrefix("c/") || formattedLink.lowercased().hasPrefix("user/") {
        return "https://youtube.com/" + formattedLink
      } else {
        // Default to channel prefix
        return "https://youtube.com/channel/" + formattedLink
      }
    case .other:
      // For other platforms, make sure it has https:// prefix
      if formattedLink.lowercased().hasPrefix("http://") || formattedLink.lowercased().hasPrefix("https://") {
        return formattedLink
      } else {
        return "https://" + formattedLink
      }
    }
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic Information")
                        .font(.headline)
                    
                    CustomTextField(title: "Business/Service Name *", text: $companyName)
                    
                    // Images Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Images")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Logo Image
                        ImagePickerButton(
                            title: "Logo",
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
                            Text("Adding portfolio images is recommended as they help showcase and promote your services.")
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
                        Text("Date Started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $dateFounded, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                    }
                    
                    // About Us
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description *")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $aboutUs)
                            .frame(height: 100)
                            .padding(8)
                            .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: colorScheme == .dark ? 0.5 : 1)
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
  @Environment(\.colorScheme) private var colorScheme
  
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
      .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
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
    @Environment(\.colorScheme) private var colorScheme
    
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
    @FocusState private var isAddressFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Address field
            VStack(alignment: .leading, spacing: 4) {
                Text("Address *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter street address", text: $address)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .focused($isAddressFieldFocused)
                    .onChange(of: address) { oldValue, newValue in
                        addressCompleter.searchAddress(newValue)
                        showAddressSuggestions = !newValue.isEmpty && isAddressFieldFocused
                    }
                    .onChange(of: isAddressFieldFocused) { oldValue, newValue in
                        if newValue {
                            showAddressSuggestions = !address.isEmpty
                        }
                    }
            }
            
            // Address suggestions
            if showAddressSuggestions && !addressCompleter.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(addressCompleter.suggestions, id: \.self) { suggestion in
                        Button(action: {
                            print("Selected address: \(suggestion.title)")
                            address = suggestion.title
                            showAddressSuggestions = false
                            isAddressFieldFocused = false
                            
                            // Try to extract city from the suggestion
                            if let cityProvince = addressCompleter.extractCityAndProvince(from: suggestion) {
                                print("Setting city to: \(cityProvince)")
                                city = cityProvince
                            } else {
                                // If we couldn't extract the city, try to use the subtitle
                                let subtitleComponents = suggestion.subtitle.components(separatedBy: ",")
                                if subtitleComponents.count >= 2 {
                                    let possibleCity = subtitleComponents[0].trimmingCharacters(in: .whitespaces)
                                    if !possibleCity.isEmpty {
                                        print("Setting city from subtitle: \(possibleCity), ON")
                                        city = "\(possibleCity), ON" // Default to Ontario
                                    }
                                }
                                
                                // Special case for Nepean addresses
                                if suggestion.title.contains("Nepean") || suggestion.subtitle.contains("Nepean") {
                                    print("Detected Nepean address, setting city to Nepean, ON")
                                    city = "Nepean, ON"
                                }
                                // Special case for Ottawa addresses
                                else if suggestion.title.contains("Ottawa") || suggestion.subtitle.contains("Ottawa") {
                                    print("Detected Ottawa address, setting city to Ottawa, ON")
                                    city = "Ottawa, ON"
                                }
                                
                                // Final fallback - if city is still empty, use a default based on the address
                                if city.isEmpty {
                                    // Try to extract any location name from the address
                                    let words = suggestion.title.components(separatedBy: " ")
                                    if words.count >= 2 {
                                        // Use the last word that's not a number as a possible city name
                                        for word in words.reversed() {
                                            let trimmedWord = word.trimmingCharacters(in: .punctuationCharacters)
                                            if !trimmedWord.isEmpty && Int(trimmedWord) == nil && trimmedWord.count > 2 {
                                                print("Using fallback city name: \(trimmedWord), ON")
                                                city = "\(trimmedWord), ON"
                                                break
                                            }
                                        }
                                    }
                                    
                                    // If still empty, use a generic value
                                    if city.isEmpty {
                                        print("Using default city: Ottawa, ON")
                                        city = "Ottawa, ON" // Default to Ottawa as a common Canadian city
                                    }
                                }
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                        }
                        Divider()
                    }
                }
                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.top, -8)
                .zIndex(1)
            }
            
            // Simplified City field
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("City *")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("(Auto-filled from address when possible)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                
                TextField("Enter city", text: $city)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .onTapGesture {
            // This will close the suggestions when tapping outside the text field
            if !isAddressFieldFocused {
                showAddressSuggestions = false
            }
        }
    }
}

class AddressCompleter: NSObject, ObservableObject {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()
    
    @Published private var addressQuery = ""
    
    private var searchTask: Task<Void, Never>?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468), // Center of Canada
            span: MKCoordinateSpan(latitudeDelta: 90, longitudeDelta: 140)
        )
        completer.resultTypes = .address
        
        // Observe address changes
        Task {
            for await _ in $addressQuery.values {
                await debounceAddressSearch()
            }
        }
    }
    
    private func debounceAddressSearch() async {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms - faster response
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                completer.resultTypes = .address
                completer.queryFragment = addressQuery
            }
        }
    }
    
    func searchAddress(_ query: String) {
        addressQuery = query
    }
    
    func extractCityAndProvince(from result: MKLocalSearchCompletion) -> String? {
        print("Attempting to extract city from: \(result.title), subtitle: \(result.subtitle)")
        
        // First try to extract from the title (which usually contains the address)
        let titleComponents = result.title.components(separatedBy: ",")
        
        // If we have at least 2 components in the title, try to extract city and province
        if titleComponents.count >= 2 {
            // The city is usually the second-to-last component
            let possibleCityIndex = titleComponents.count >= 3 ? titleComponents.count - 2 : 0
            let cityComponent = titleComponents[possibleCityIndex].trimmingCharacters(in: .whitespaces)
            
            // The province is usually the last component
            let provinceComponent = titleComponents.last?.trimmingCharacters(in: .whitespaces) ?? ""
            
            // Check if it's a Canadian province
            let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
            let foundProvince = provinces.first { provinceComponent.contains($0) }
            
            if let province = foundProvince {
                let result = "\(cityComponent), \(province)"
                print("Extracted city and province from title: \(result)")
                return result
            }
        }
        
        // If we couldn't extract from the title, try the subtitle
        let subtitleComponents = result.subtitle.components(separatedBy: ",")
        
        // Look for a component that contains a Canadian province
        let provinces = ["Alberta", "British Columbia", "Manitoba", "New Brunswick", 
                         "Newfoundland and Labrador", "Nova Scotia", "Northwest Territories", 
                         "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon",
                         "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
        
        for (index, component) in subtitleComponents.enumerated() {
            let trimmedComponent = component.trimmingCharacters(in: .whitespaces)
            
            // Check if this component contains a province
            if provinces.contains(where: { trimmedComponent.contains($0) }) {
                // If we found a province and there's a component before it, that's likely the city
                if index > 0 {
                    let cityComponent = subtitleComponents[index - 1].trimmingCharacters(in: .whitespaces)
                    let result = "\(cityComponent), \(trimmedComponent)"
                    print("Extracted city and province from subtitle: \(result)")
                    return result
                } else if subtitleComponents.count > 1 {
                    // If the province is the first component, the city might be the next one
                    let cityComponent = subtitleComponents[1].trimmingCharacters(in: .whitespaces)
                    let result = "\(cityComponent), \(trimmedComponent)"
                    print("Extracted city and province from subtitle (alternate order): \(result)")
                    return result
                }
            }
        }
        
        // If we still couldn't find a city and province, check if "Canada" is in the subtitle
        // and use the component before it as the city with a generic "ON" province
        if result.subtitle.contains("Canada") {
            let components = result.subtitle.components(separatedBy: ",")
            if components.count >= 2 {
                // Try to find the component before "Canada"
                for (index, component) in components.enumerated() {
                    if component.trimmingCharacters(in: .whitespaces) == "Canada" && index > 0 {
                        let cityComponent = components[index - 1].trimmingCharacters(in: .whitespaces)
                        // Check if this component contains a province code
                        let containsProvince = provinces.contains { cityComponent.contains($0) }
                        
                        if !containsProvince {
                            let result = "\(cityComponent), ON" // Default to Ontario if unknown
                            print("Extracted city with default province: \(result)")
                            return result
                        }
                    }
                }
            }
        }
        
        print("Failed to extract city and province")
        return nil
    }
}

extension AddressCompleter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            // Don't filter strictly for Canadian addresses
            // This allows more results to show up, including street addresses
            self.suggestions = completer.results
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Service Details")
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
                            .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        if workHoursType == .custom {
                            TextField("Enter custom working hours", text: $customWorkHours)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
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
                        Text("Service Model")
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
    @Environment(\.colorScheme) private var colorScheme
    
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
            .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
  AddCompanyView(viewModel: AddCompanyViewModel(), entrepreneur: createStubEntrepreneurs()[0])
}
