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
  @Binding var showSignInView: Bool
  @Binding var userIsLoggedIn: Bool
  
  var body: some View {
      NavigationStack {
          List(viewModel.categories, id: \.self) { category in
              NavigationLink(destination: CompaniesListView(category: category)) {
                  HStack {
                      Image(systemName: "car.fill")
                          .frame(width: 50, height: 50)
                          .foregroundColor(Color.purple1)
                      Text(category.name)
                          .font(.headline)
                  }
              }
          }
          .listStyle(PlainListStyle())
          .padding(.top, -8) // Adjust this value as needed
          .navigationTitle("Business Directory")
          .navigationBarTitleDisplayMode(.inline)
      }
      .customNavigationBar(showSignInView: $showSignInView, isLoggedIn: userIsLoggedIn)
  }
}

struct DirectoryListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DirectoryListView(viewModel: DirectoryListViewModel(), showSignInView: .constant(false), userIsLoggedIn: .constant(false))
    }
  }
}
