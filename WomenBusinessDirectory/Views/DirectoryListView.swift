//
//  DirectoryListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import SwiftData

struct DirectoryListView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var companies: [Company]
    let categories = [
        Category(name: "Media & Digital Services", image: "digital_marketing"),
        Category(name: "Financial Services", image: "financial_service"),
        Category(name: "Health and Wellness", image: "health"),
        Category(name: "Professional Services", image: "professional_service"),
        Category(name: "Technology", image: "technology"),
        Category(name: "Food and Beverage", image: "food_beverage"),
        Category(name: "Retail", image: "retail")
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Categories")
                    .font(.title2)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach([Category](Set(companies.map{$0.category})), id: \.self) { category in
                            NavigationLink(destination: CompaniesListView(category: category)) {
                                CardView(category: category)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Business Directory")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background {
//                Color.lightPurple.opacity(0.5)
//                    .ignoresSafeArea()
//            }
        }
        
    }
}

struct CategoryListView_Previews: PreviewProvider {

    static var previews: some View {
        let categories = [
            Category(name: "Media & Digital Services", image: "digital_marketing"),
            Category(name: "Technology", image: "technology"),
            Category(name: "Food and Beverage", image: "food_beverage"),
            Category(name: "Financial Services", image: "financial_service"),
            Category(name: "Professional Services", image: "professional_service"),
            Category(name: "Health and Wellness", image: "health"),
            Category(name: "Retail", image: "retail")
        ]
        
        DirectoryListView()
        
        ForEach(1...6, id: \.self) { number in
            CardView(category: categories[number - 1])
                .modelContainer(for: Company.self, inMemory: true)
        }
    }
}
