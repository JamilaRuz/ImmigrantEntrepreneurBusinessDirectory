//
//  CompaniesListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI

@MainActor
class CompaniesListViewModel: ObservableObject {
  private var companyManager: CompanyManager?
  private var category: Category?
  
  @Published var companies: [Company] = []
  @Published var allCategories: [Category] = []
  
  func setup(companyManager: CompanyManager, category: Category) {
    self.companyManager = companyManager
    self.category = category
      
    Task {
      do {
        async let companiesTask = loadCompanies()
        async let categoriesTask = loadAllCategories()
        
        self.companies = try await companiesTask
        self.allCategories = try await categoriesTask
      } catch {
        print("Failed to load data: \(error)")
      }
    }
  }
  
  private func loadCompanies() async throws -> [Company] {
    guard let companyManager = companyManager, let category = category else {
      return []
    }
    
    return try await companyManager.getCompaniesByCategory(categoryId: category.categoryId)
  }
  
  private func loadAllCategories() async throws -> [Category] {
    return try await CategoryManager.shared.getCategories()
  }
  
  func getCategoryNames(for company: Company) -> String {
    let names = company.categoryIds.compactMap { categoryId in
      allCategories.first(where: { $0.categoryId == categoryId })?.name
    }
    return names.joined(separator: ", ")
  }
}

struct CompaniesListView: View {
  var category: Category
  
  @Environment(\.companyManager) var companyManager: CompanyManager
  @StateObject private var viewModel: CompaniesListViewModel = CompaniesListViewModel()
  
  @State private var searchTerm = ""
  
  init(category: Category) {
    self.category = category
  }
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        SearchBar(text: $searchTerm)
          .padding(.horizontal)
          .padding(.top)
        
        List {
          ForEach(viewModel.companies, id: \.self) { company in
            NavigationLink(destination: CompanyDetailView(company: company)) {
              CompanyRowView(company: company, viewModel: viewModel)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
          }
        }
        .listStyle(.plain)
      }
      .background(Color.white)
      .navigationTitle(category.name)
      .navigationBarTitleDisplayMode(.inline)
    }
    .onAppear {
      viewModel.setup(companyManager: companyManager, category: category)
    }
  }
}

struct SearchBar: View {
  @Binding var text: String
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      TextField("Search", text: $text)
      if !text.isEmpty {
        Button(action: { text = "" }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
      }
    }
    .padding(8)
    .background(Color(.systemGray6))
    .cornerRadius(10)
  }
}

struct CompanyRowView: View {
    let company: Company
    @ObservedObject var viewModel: CompaniesListViewModel
  
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "building.2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(company.name)
                            .font(.headline)
                        Text(viewModel.getCategoryNames(for: company))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text(company.workHours)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Text(company.aboutUs)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Services
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(company.services, id: \.self) { service in
                            Text(service)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    let category = Category(categoryId: "1", name: "Computers & Electronics")
    let viewModel = CompaniesListViewModel()
    viewModel.setup(companyManager: StubCompanyManager(), category: category)
    return NavigationStack {
        CompaniesListView(category: category)
            .environment(\.companyManager, StubCompanyManager())
            .environmentObject(viewModel)
    }
}
