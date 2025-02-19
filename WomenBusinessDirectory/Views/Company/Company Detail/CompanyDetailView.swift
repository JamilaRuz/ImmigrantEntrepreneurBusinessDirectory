//
//  CompanyDetailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI

struct CompanyDetailView: View {
  @Environment(\.dismiss) var dismiss
  var company: Company
  @State private var selectedSegment = 0
  @State private var isBookmarked: Bool
  
  init(company: Company) {
    self.company = company
    _isBookmarked = State(initialValue: company.isBookmarked)
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        // Header Section
        ZStack(alignment: .bottom) {
          // Header Image with Gradient
          AsyncImage(url: URL(string: company.headerImg ?? "")) { phase in
            switch phase {
            case .empty:
              Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 300)
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
            case .failure:
              Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 300)
            @unknown default:
              EmptyView()
            }
          }
          .overlay(
            LinearGradient(
              gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          
          // Company Logo and Name with Action Buttons
          VStack(spacing: 16) {
            // Logo
            AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
              switch phase {
              case .empty:
                Circle()
                  .fill(Color.gray.opacity(0.3))
                  .frame(width: 80, height: 80)
              case .success(let image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 80, height: 80)
                  .clipShape(Circle())
                  .overlay(Circle().stroke(Color.white, lineWidth: 2))
              case .failure:
                Circle()
                  .fill(Color.gray.opacity(0.3))
                  .frame(width: 80, height: 80)
              @unknown default:
                EmptyView()
              }
            }
            
            Text(company.name)
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(.white)
              .multilineTextAlignment(.center)
              .padding(.horizontal, 20)
          }
          .padding(.bottom, 20)
          
          // Action buttons at bottom right
          HStack {
            Spacer()
            HStack(spacing: 12) {
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
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 30))
          }
          .padding(.bottom, 20)
        }
        .frame(height: 300)
        
        VStack(spacing: 0) {
          // Custom Tab Bar
          HStack(spacing: 0) {
            ForEach(["Info", "Products", "Map"], id: \.self) { tab in
              Button(action: {
                withAnimation {
                  selectedSegment = ["Info", "Products", "Map"].firstIndex(of: tab) ?? 0
                }
              }) {
                VStack(spacing: 8) {
                  Text(tab)
                    .font(.subheadline)
                    .fontWeight(selectedSegment == ["Info", "Products", "Map"].firstIndex(of: tab) ? .semibold : .regular)
                  
                  Rectangle()
                    .fill(selectedSegment == ["Info", "Products", "Map"].firstIndex(of: tab) ? Color.blue : Color.clear)
                    .frame(height: 2)
                }
              }
              .foregroundColor(selectedSegment == ["Info", "Products", "Map"].firstIndex(of: tab) ? .blue : .gray)
              .frame(maxWidth: .infinity)
            }
          }
          .padding(.vertical, 16)
          .padding(.horizontal, 20)
          
          // Tab Content
          TabView(selection: $selectedSegment) {
            InfoView(company: company)
              .tag(0)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            ProductsView(services: company.services, portfolioImages: company.portfolioImages)
              .tag(1)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            MapView(company: company)
              .tag(2)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .frame(minHeight: 400)
          .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
          
          // Action Buttons
          HStack(spacing: 20) {
            Button(action: {
              // Open Now action
            }) {
              HStack {
                Image(systemName: "clock.fill")
                Text("Open Now")
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
              .background(Color.blue.opacity(0.2))
              .foregroundColor(.blue)
              .cornerRadius(12)
            }
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 16)
        }
        .padding(.horizontal, 20)
      }
    }
    .ignoresSafeArea(.all, edges: .top)
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
