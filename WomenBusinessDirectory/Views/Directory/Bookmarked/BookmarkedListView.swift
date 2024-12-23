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
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top, spacing: 12) {
                                        AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                                            switch phase {
                                            case .empty, .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 60, height: 60)
                                                    .background(Color.gray.opacity(0.2))
                                                    .cornerRadius(12)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(company.name)
                                                .font(.headline)
                                            
                                            // Categories horizontal scroll
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 8) {
                                                    ForEach(company.categoryIds, id: \.self) { categoryId in
                                                        if let category = viewModel.categories.first(where: { $0.id == categoryId }) {
                                                            Text(category.name)
                                                                .font(.caption)
                                                                .padding(.horizontal, 8)
                                                                .padding(.vertical, 4)
                                                                .background(Color.yellow.opacity(0.2))
                                                                .foregroundColor(.orange)
                                                                .cornerRadius(8)
                                                        }
                                                    }
                                                }
                                            }
                                            
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
                                    
                                    // Services scroll remains the same
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
