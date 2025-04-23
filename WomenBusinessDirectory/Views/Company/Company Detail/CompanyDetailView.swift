//
//  CompanyDetailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI

struct CompanyDetailView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) private var colorScheme
  let company: Company
  @State private var selectedSegment = 0
  @State private var isBookmarked: Bool
  
  init(company: Company) {
    self.company = company
    _isBookmarked = State(initialValue: company.isBookmarked)
  }
  
  var body: some View {
    Group {
      GeometryReader { geometry in
        VStack(spacing: 0) {
          ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
              // Header Image with Gradient
              CachedAsyncImage(url: URL(string: company.headerImg ?? "")) { phase in
                switch phase {
                case .empty:
                  Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                case .success(let image):
                  image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .frame(maxWidth: geometry.size.width)
                case .failure:
                  Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                }
              }
              .overlay(
                LinearGradient(
                  gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
              .overlay(
                VStack(spacing: 16) {
                  Spacer()
                  // Logo
                  CachedAsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                    switch phase {
                    case .empty:
                      Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    case .success(let image):
                      image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    case .failure:
                      Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                  }
                  
                  Text(company.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
              )
              .overlay(
                HStack {
                  Spacer()
                  VStack(spacing: 12) {
                    Button(action: toggleBookmark) {
                      Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                    }
                    Button(action: shareCompany) {
                      Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                    }
                  }
                  .padding(20)
                },
                alignment: .bottomTrailing
              )

              // Custom Tab Bar
              HStack(spacing: 0) {
                ForEach(["Info", "Products"], id: \.self) { tab in
                  Button(action: {
                    withAnimation {
                      selectedSegment = ["Info", "Products"].firstIndex(of: tab) ?? 0
                    }
                  }) {
                    VStack(spacing: 8) {
                      Text(tab)
                        .font(.subheadline)
                        .fontWeight(selectedSegment == ["Info", "Products"].firstIndex(of: tab) ? .semibold : .regular)
                      
                      Rectangle()
                        .fill(selectedSegment == ["Info", "Products"].firstIndex(of: tab) ? Color.blue : Color.clear)
                        .frame(height: 2)
                    }
                  }
                  .foregroundColor(selectedSegment == ["Info", "Products"].firstIndex(of: tab) ? .blue : .gray)
                  .frame(maxWidth: .infinity)
                }
              }
              .padding(.vertical, 16)
              .background(colorScheme == .dark ? Color.black : Color.white)
              
              // Content area with TabView
              TabView(selection: $selectedSegment) {
                InfoView(company: company)
                    .tag(0)
                    .id("info")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                ProductsView(services: company.services, portfolioImages: company.portfolioImages)
                    .tag(1)
                    .id("products")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              }
              .frame(minHeight: max(600, geometry.size.height - 200)) // Ensure there's enough height to show all content
              .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
              .animation(nil, value: selectedSegment)
            }
          }
          
          // Action Buttons - Fixed at the bottom
          VStack {
            HStack(spacing: 20) {
              Button(action: {
                // Email Us action
                let emailAddress = company.email
                
                // Create the mailto URL
                guard let mailtoURL = URL(string: "mailto:\(emailAddress)") else {
                  print("Failed to create mailto URL")
                  return
                }
                
                print("mailtoURL: \(mailtoURL)")
                  
                // Check if the device can open the URL
                if UIApplication.shared.canOpenURL(mailtoURL) {
                  UIApplication.shared.open(mailtoURL, options: [:]) { success in
                    if !success {
                      print("Failed to open mail app: \(mailtoURL)")
                    }
                  }
                } else {
                  print("Cannot open mail app. URL scheme not supported: \(mailtoURL)")
                }
              }) {
                HStack {
                  Image(systemName: "envelope.fill")
                  Text("Email Us")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(12)
              }
              
              Button(action: {
                guard let url = URL(string: "tel://\(company.phoneNum)") else { return }
                UIApplication.shared.open(url)
              }) {
                HStack {
                  Image(systemName: "phone.fill")
                  Text("Call")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(company.phoneNum.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                .foregroundColor(company.phoneNum.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(12)
              }
              .disabled(company.phoneNum.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(colorScheme == .dark ? Color.black : Color.white)
          }
        }
      }
    }
    .ignoresSafeArea(edges: .top)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func toggleBookmark() {
    Task {
      do {
        isBookmarked.toggle()
        try await RealCompanyManager.shared.updateBookmarkStatus(for: company, isBookmarked: isBookmarked)
      } catch {
        isBookmarked.toggle()
        print("Failed to update bookmark status: \(error.localizedDescription)")
      }
    }
  }
  
  private func shareCompany() {
    let shareText = """
    Check out \(company.name)!
    \(company.aboutUs)
    
    Contact:
    📞 \(company.phoneNum)
    📍 \(company.address), \(company.city)
    """
    
    let av = UIActivityViewController(
      activityItems: [shareText],
      applicationActivities: nil
    )
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first,
       let rootVC = window.rootViewController {
      rootVC.present(av, animated: true)
    }
  }
}

#Preview {
  CompanyDetailView(company: createStubCompanies()[0])
}
