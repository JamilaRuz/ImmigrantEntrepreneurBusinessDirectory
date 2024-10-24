//
//  BookmarkedListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI

struct BookmarkedListView: View {
    @Environment(\.companyManager) private var companyManager
    @State private var bookmarkedCompanies: [Company] = []

    var body: some View {
        NavigationView {
            List(bookmarkedCompanies, id: \.companyId) { company in
                NavigationLink(destination: CompanyDetailView(company: company)) {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                            switch phase {
                            case .empty:
                                // Placeholder while the image is loading
                                ProgressView()
                            case .success(let image):
                                // Display the image
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100) // Adjust the size as needed
                            case .failure:
                                // Display a default image or placeholder on failure
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100) // Adjust the size as needed
                            @unknown default:
                                // Handle any future cases
                                EmptyView()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(company.name)
                                .font(.headline)
                                .foregroundColor(.purple)
                            Text(company.categoryIds.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text(company.aboutUs)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.green)
                                Text(company.workHours)
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Bookmarked")
            .onAppear {
                loadBookmarkedCompanies()
            }
        }
    }
    
    private func loadBookmarkedCompanies() {
        Task {
            do {
                let companies = try await RealCompanyManager.shared.getBookmarkedCompanies()
                bookmarkedCompanies = companies
            } catch {
                print("Failed to load companies: \(error)")
            }
        }
    }
}

#Preview {
    BookmarkedListView()
}
