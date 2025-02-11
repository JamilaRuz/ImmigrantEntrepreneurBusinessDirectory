//
//  BookmarkedListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI

@MainActor
class BookmarkedListViewModel: ObservableObject {
    @Published var bookmarkedCompanies: [Company] = []
    @Published var categories: [Category] = []
    
    func loadBookmarkedCompanies() {
        Task {
            do {
                let companies = try await RealCompanyManager.shared.getBookmarkedCompanies()
                bookmarkedCompanies = companies
                categories = try await CategoryManager.shared.getCategories()
            } catch {
                print("Failed to load companies: \(error)")
            }
        }
    }
    
    func getCategoryNames(for company: Company) -> String {
        let names = company.categoryIds.compactMap { categoryId in
            categories.first(where: { $0.id == categoryId })?.name
        }
        return names.joined(separator: ", ")
    }
}

struct BookmarkedListView: View {
    @StateObject private var viewModel = BookmarkedListViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.bookmarkedCompanies.isEmpty {
                    EmptyBookmarkedListView()
                } else {
                    List(viewModel.bookmarkedCompanies, id: \.companyId) { company in
                        NavigationLink(destination: CompanyDetailView(company: company)) {
                            CompanyRowView(company: company, categories: viewModel.categories)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Bookmarked")
            .onAppear {
                viewModel.loadBookmarkedCompanies()
            }
        }
    }
}

#Preview {
    BookmarkedListView()
}
