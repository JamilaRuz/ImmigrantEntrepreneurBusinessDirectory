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
  
  func setup(companyManager: CompanyManager, category: Category) {
    self.companyManager = companyManager
    self.category = category
      
    Task {
      do {
        self.companies = try await loadCompanies()
      } catch {
        // TODO handle error
        print("Failed to load companies: \(error)")
      }
    }
  }
  
  private func loadCompanies() async throws -> [Company] {
    guard let companyManager = companyManager, let category = category else {
      return []
    }
    
    return try await companyManager.getCompaniesByCategory(categoryId: category.categoryId)
  }
}

struct CompaniesListView: View {
  var category: Category
  
  @Environment(\.companyManager) var companyManager: CompanyManager
  @StateObject private var viewModel: CompaniesListViewModel = CompaniesListViewModel() // .setup is called in onAppear
  
  @State private var searchTerm = ""
  
  init(category: Category) {
    self.category = category
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        List() {
          ForEach(viewModel.companies, id: \.self) { company in
            NavigationLink(destination: CompanyDetailView(company: company)) {
              HStack {
                Image("company_logo1") // TODO company.logoImg
                  .resizable()
                  .scaledToFit()
                  .frame(width: 100, height: 130)
                  .cornerRadius(5)
                  .border(Color.gray, width: 1)
                
                VStack(alignment: .leading, spacing: 10) {
                  Text(company.name)
                    .font(.system(size: 18, weight: .medium))
                  Text(company.aboutUs)
                    .font(.system(size: 14, weight: .regular))
                    .lineLimit(3)
                  Text(company.address)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 5)
              }
            }
          }
        }
        .background(Color.white)
        .listStyle(.grouped)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .cornerRadius(10)
      .navigationTitle("Companies")
      .searchable(text: $searchTerm, prompt: "Company name")
      .onAppear {
        viewModel.setup(companyManager: companyManager, category: category)
      }
    }
  }
}

#Preview {
  let category = Category(categoryId: "1", name: "Category 1")
  return CompaniesListView(category: category)
    .environment(\.companyManager, StubCompanyManager())
}
