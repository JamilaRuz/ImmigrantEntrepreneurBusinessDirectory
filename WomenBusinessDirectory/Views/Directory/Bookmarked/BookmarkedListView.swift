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
            ScrollView {
                if viewModel.bookmarkedCompanies.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 70))
                            .foregroundColor(Color.green1)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.green1.opacity(0.1))
                                    .frame(width: 120, height: 120)
                            )
                        
                        Text("No Bookmarks Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.green1)
                        
                        Text("Browse the directory and bookmark companies you're interested in to see them here.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 32)
                        
                        NavigationLink(destination: DirectoryListView(viewModel: DirectoryListViewModel(), showSignInView: .constant(false), userIsLoggedIn: .constant(false))) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Browse Directory")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green1)
                            .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green1.opacity(0.1),
                                Color.white
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                } else {
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
            .background(Color(.systemGray6))
            .navigationTitle("Bookmarked")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadBookmarkedCompanies()
            }
        }
        .tint(Color.green1)
    }
}

#Preview {
    BookmarkedListView()
}
