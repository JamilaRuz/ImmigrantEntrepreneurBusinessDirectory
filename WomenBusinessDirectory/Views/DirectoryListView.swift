//
//  DirectoryListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI

@MainActor
final class DirectoryListViewModel: ObservableObject {
  @Published private(set) var categories: [Category] = []

  init() {
    Task {
      do {
        try await loadCategories()
      } catch {
        // TODO handle error
        print("Failed to load categories: \(error)")
      }
    }
  }
  
  private func loadCategories() async throws {
    self.categories = try await CategoryManager.shared.getCategories()
  }
}

struct DirectoryListView: View {
  @StateObject var viewModel: DirectoryListViewModel

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
            ForEach(viewModel.categories, id: \.self) { category in
              NavigationLink(destination: CompaniesListView(viewModel: CompaniesListViewModel(category: category))) {
                CardView(category: category)
              }
            }
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
  DirectoryListView(viewModel: DirectoryListViewModel())
}
