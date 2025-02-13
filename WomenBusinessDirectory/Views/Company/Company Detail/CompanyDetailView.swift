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
    VStack(spacing: 0) {
      // Header image and company name overlay
      ZStack {
        AsyncImage(url: URL(string: company.portfolioImages.first ?? "")) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(height: 300)
              .clipped()
          case .failure:
            Image(systemName: "photo")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 300)
              .foregroundColor(.gray)
          @unknown default:
            EmptyView()
          }
        }
        .frame(height: 300)
        
        VStack {
          Spacer()
          HStack {
            Text(company.name)
              .font(.title)
              .fontWeight(.semibold)
              .foregroundColor(.white)
              .shadow(radius: 10)
              .padding(7)
              .background(Color.black.opacity(0.3))
              .cornerRadius(10)
            Spacer()
          }
        }
        .padding(.horizontal, 30)
      }
      .frame(height: 300)
      
      // Content container with padding
      VStack(spacing: 0) {
        // Bookmark Button
        HStack {
          Button(action: toggleBookmark) {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
              .foregroundColor(Color("purple1"))
              .padding()
          }
          Spacer()
        }
        
        // Segments
        Picker("Segments", selection: $selectedSegment) {
          Text("Info").tag(0)
          Text("Products").tag(1)
          Text("Map").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        
        // Tab content
        TabView(selection: $selectedSegment) {
          InfoView(company: company)
            .tag(0)
            ProductsView(services: company.services, portfolioImages: company.portfolioImages)
            .tag(1)
          MapView(company: company)
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
        Spacer()
        
        // Bottom buttons
        HStack(spacing: 20) {
          Button(action: {
            // Open Now action
          }) {
            Text("Open Now")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.green.opacity(0.2))
              .foregroundColor(.green)
              .cornerRadius(10)
          }
          
          Button(action: {
            // Make a Call action
          }) {
            Text("Make a Call")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.red.opacity(0.2))
              .foregroundColor(.red)
              .cornerRadius(10)
          }
        }
      }
      .padding(.horizontal, 16) // Add horizontal padding to entire content container
    }
    .edgesIgnoringSafeArea(.top) // Keep this to allow the header image to extend to the edges
  }
  
  private func toggleBookmark() {
    Task {
      do {
        isBookmarked.toggle()
        try await RealCompanyManager.shared.updateBookmarkStatus(for: company, isBookmarked: isBookmarked)
      } catch {
        // Revert the toggle if the update fails
        isBookmarked.toggle()
        print("Failed to update bookmark status: \(error.localizedDescription)")
        // TODO: Show error to user
      }
    }
  }
}

#Preview {
  CompanyDetailView(company: createStubCompanies()[0])
}
