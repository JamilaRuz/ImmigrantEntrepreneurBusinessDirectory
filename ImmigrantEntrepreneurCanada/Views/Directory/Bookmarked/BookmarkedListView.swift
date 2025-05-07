//
//  BookmarkedListView.swift
//  ImmigrantEntrepreneurCanada
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
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    
    // Add color scheme environment to detect dark mode
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.bookmarkedCompanies.isEmpty {
                    VStack(spacing: 16) {
                        Text("No Bookmarks Yet")
                            .font(.title2)
                            .foregroundColor(colorScheme == .dark ? .white : Color.green1)
                        Text("Browse the directory and bookmark companies you're interested in to see them here.")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .gray : Color.green1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: -30)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.bookmarkedCompanies, id: \.companyId) { company in
                                NavigationLink {
                                    CompanyDetailView(company: company)
                                } label: {
                                    CompanyRowView(company: company, categories: viewModel.categories)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Bookmarked")
            .navigationBarTitleDisplayMode(.inline)
            .customNavigationBar(
                showSignInView: $showSignInView,
                isLoggedIn: $userIsLoggedIn
            )
            .onAppear {
                viewModel.loadBookmarkedCompanies()
                
                // Update login status
                if let _ = try? AuthenticationManager.shared.getAuthenticatedUser() {
                    userIsLoggedIn = true
                }
            }
        }
        .tint(colorScheme == .dark ? .white : Color.green1)
    }
}

#Preview {
    BookmarkedListView(showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}
