//
//  CompanyDetailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI

struct CompanyDetailView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var viewModel = CompanyDetailViewModel()
  let companyId: String
  @State private var selectedSegment = 0
  @State private var isBookmarked: Bool
  
  init(company: Company) {
    self.companyId = company.companyId
    _isBookmarked = State(initialValue: company.isBookmarked)
  }
  
  var body: some View {
    Group {
      if let company = viewModel.company {
        ScrollView(showsIndicators: false) {
          VStack(spacing: 0) {
            // Header Image with Gradient
            AsyncImage(url: URL(string: company.headerImg ?? "")) { phase in
              switch phase {
              case .empty:
                Rectangle()
                  .fill(Color.gray.opacity(0.3))
                  .frame(height: 300)
                  .frame(maxWidth: .infinity)
              case .success(let image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(height: 300)
                  .frame(maxWidth: .infinity)
                  .clipped()
              case .failure:
                Rectangle()
                  .fill(Color.gray.opacity(0.3))
                  .frame(height: 300)
                  .frame(maxWidth: .infinity)
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
            .overlay(
              VStack(spacing: 16) {
                Spacer()
                // Logo
                AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
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
                  @unknown default:
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
              
              TabView(selection: $selectedSegment) {
                InfoView(company: company)
                  .tag(0)
                ProductsView(services: company.services, portfolioImages: company.portfolioImages)
                  .tag(1)
                MapView(company: company)
                  .tag(2)
              }
              .frame(minHeight: 400)
              .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
              
              // Action Buttons
              VStack {
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
                .padding(.horizontal)
                .padding(.vertical, 16)
              }
            }
            .background(Color.white)
          }
        }
      } else {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .ignoresSafeArea(edges: .top)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task {
        await viewModel.loadCompany(companyId: companyId)
      }
    }
  }
  
  private func toggleBookmark() {
    Task {
      do {
        isBookmarked.toggle()
        if let company = viewModel.company {
          try await RealCompanyManager.shared.updateBookmarkStatus(for: company, isBookmarked: isBookmarked)
        }
      } catch {
        isBookmarked.toggle()
        print("Failed to update bookmark status: \(error.localizedDescription)")
      }
    }
  }
  
  private func shareCompany() {
    guard let company = viewModel.company else { return }
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

@MainActor
class CompanyDetailViewModel: ObservableObject {
  @Published var company: Company?
  
  func loadCompany(companyId: String) async {
    do {
      self.company = try await RealCompanyManager.shared.getCompany(companyId: companyId)
    } catch {
      print("Failed to load company: \(error)")
    }
  }
}

#Preview {
  CompanyDetailView(company: createStubCompanies()[0])
}
