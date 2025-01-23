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
    ScrollView {
      VStack(spacing: 24) {
        logoAndAboutUsView
          .padding(.horizontal)
        
        VStack(alignment: .leading, spacing: 16) {
          Text("Company Details")
            .font(.headline)
            .padding(.horizontal)
          
          VStack(spacing: 16) {
            CustomTextField(title: "Company Name", text: $companyName)
            
            VStack(alignment: .leading, spacing: 8) {
              Text("Date Founded")
                .font(.subheadline)
                .foregroundColor(.gray)
              DatePicker("", selection: $dateFounded, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
            }
            .padding(.horizontal)
          }
        }
        
        categoriesSection
        ownershipSection
        portfolioSection
      }
      .padding(.vertical)
    }
  }
  
  private var logoAndAboutUsView: some View {
    HStack(alignment: .top, spacing: 20) {
      Button(action: { isImagePickerPresented = true }) {
        VStack {
          if let logoImage = logoImage {
            Image(uiImage: logoImage)
              .resizable()
              .scaledToFill()
              .frame(width: 120, height: 120)
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.gray.opacity(0.3), lineWidth: 1)
              )
          } else {
            VStack(spacing: 8) {
              Image(systemName: "camera.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
              Text("Add Logo")
                .font(.caption)
                .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
        }
      }
      .buttonStyle(PlainButtonStyle())
      
      VStack(alignment: .leading, spacing: 8) {
        Text("About Company")
          .font(.subheadline)
          .foregroundColor(.gray)
        TextEditor(text: $aboutUs)
          .frame(height: 120)
          .padding(8)
          .background(Color.gray.opacity(0.1))
          .cornerRadius(12)
      }
    }
  }
  
  private var categoriesSection: some View {
    VStack(alignment: .leading, spacing: 16) {
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
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
      }
      
      if !selectedCategoryIds.isEmpty {
        selectedCategoriesView
          .padding(.horizontal)
      }
    }
  }
  
  private var ownershipSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Ownership Type")
        .font(.headline)
        .padding(.horizontal)
      
      VStack(spacing: 12) {
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
                .foregroundColor(.primary)
              Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
          }
        }
      }
      .padding(.horizontal)
    }
  }
  
  private var portfolioSection: some View {
    VStack(alignment: .leading, spacing: 16) {
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
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
      }
      
      if !portfolioImages.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 12) {
            ForEach(portfolioImages.indices, id: \.self) { index in
              Image(uiImage: portfolioImages[index])
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
  
  private var selectedCategoriesView: some View {
    let selectedCategories = viewModel.categories.filter { selectedCategoryIds.contains($0.id) }
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
