//
//  CompaniesListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI
import SwiftData

struct CompaniesListView: View {
    var category: Category
    
    @Environment(\.modelContext) var modelContext
    @Query private var companies: [Company]
    @State private var searchTerm = ""
    
    var filteredCompanies: [Company] {
        let categoryFiltered = companies.filter {$0.category == category}
        guard !searchTerm.isEmpty else { return categoryFiltered }
        
        return categoryFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List() {
                    ForEach(filteredCompanies, id: \.self) { company in
                        NavigationLink(destination: CompanyDetailView(company: company)) {
                            HStack {
                                Image(company.logoImg)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 80)
                                    .cornerRadius(5)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(company.name)
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    HStack {
                                        if company.isFavorite {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.accentColor)
                                        }
                                        Text(company.address)
                                            .font(.system(size: 14, weight: .regular))
                                    }
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
    CompaniesListView(category: Category(name: "Breakfasts", image: "breakfast1"))
        .modelContainer(for: Company.self, inMemory: true)
}

