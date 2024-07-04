//
//  CompaniesListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI

@MainActor
final class CompaniesListViewModel: ObservableObject {
  var category: Category
  @Published private(set) var companies: [Company] = []

  init(category: Category) {
    self.category = category
    Task {
      do {
        try await loadCompanies()
      } catch {
        // TODO handle error
        print("Failed to load companies: \(error)")
      }
    }
  }
  
  private func loadCompanies() async throws {
    self.companies = try await CompanyManager.shared.getCompaniesByCategory(categoryId: category.categoryId)
  }
}

struct CompaniesListView: View {
  @StateObject var viewModel: CompaniesListViewModel
  
  @State private var searchTerm = ""
  
  var body: some View {
    NavigationStack {
      VStack {
        List() {
          ForEach(viewModel.companies, id: \.self) { company in
            NavigationLink(destination: CompanyDetailView(company: company)) {
              HStack {
                Image("placeholder") // TODO company.logoImg
                  .resizable()
                  .scaledToFill()
                  .frame(width: 100, height: 80)
                  .cornerRadius(5)
                
                VStack(alignment: .leading, spacing: 5) {
                  Text(company.name)
                    .font(.system(size: 18, weight: .medium))
                  
                  //                                    HStack {
                  //                                        if company.isFavorite {
                  //                                            Image(systemName: "heart.fill")
                  //                                                .foregroundColor(.accentColor)
                  //                                        }
                  //                                        Text(company.address)
                  //                                            .font(.system(size: 14, weight: .regular))
                  //                                    }
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
    }
  }
}

#Preview {
  let category = Category(categoryId: "1", name: "Category 1")
  return CompaniesListView(
    viewModel: CompaniesListViewModel(category: category)
  )
}
