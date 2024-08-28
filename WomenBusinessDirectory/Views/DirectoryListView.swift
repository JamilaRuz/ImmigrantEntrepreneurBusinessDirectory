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
    self.categories = try await CategoryManager.shared.getCategories().sorted { $0.name < $1.name }
  }
}

struct DirectoryListView: View {
  @StateObject var viewModel: DirectoryListViewModel
  @State private var selectedCategory: Category? = nil
  
  var body: some View {
    NavigationStack {
      VStack {
        List(viewModel.categories, id: \.self) { category in
          NavigationLink(destination: CompaniesListView(category: category)) {
            HStack() {
              Image(systemName: "car.fill") // TODO: Replace with actual image
                .frame(width: 50, height: 50)
                .foregroundColor(Color.green4)
              Text(category.name)
                .font(.headline)
            }
          }
          //        .background(selectedCategory == category ? Color.green4.opacity(0.5) : Color.clear)
          //        .onTapGesture {
          //          selectedCategory = category
          //        }
        }
      }
      .navigationTitle("Bussiness Directory")
    }
  }
}

#Preview {
  DirectoryListView(viewModel: DirectoryListViewModel())
}
