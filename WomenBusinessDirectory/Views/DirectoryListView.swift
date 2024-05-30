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
  @Query(sort: \Company.name, order: .forward) private var companies: [Company]
  
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
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            NavigationLink(destination: AddProfileView()) {
              Label("Profile", systemImage: "person")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
              .font(.title)
              .foregroundColor(.black)
              .accessibilityLabel("Menu")
          }
        }
      }
      .padding()
      .navigationTitle("Business Directory")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background {
        Color.green1.opacity(0.5)
          .ignoresSafeArea()
      }
    }
//    .onAppear {
//      print("company \(companies[1].name) \(companies[1].entrepreneurs.count)")
//    }
  }
}

#Preview {
  DirectoryListView()
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
