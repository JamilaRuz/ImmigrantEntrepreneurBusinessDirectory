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
  
  func loadCategories() {
    Task {
      do {
        self.categories = try await CategoryManager.shared.getCategories().sorted { $0.name < $1.name }
      } catch {
        print("Failed to load categories: \(error)")
      }
    }
  }
}

struct DirectoryListView: View {
  @StateObject var viewModel = DirectoryListViewModel()
  @State private var selectedCategory: Category? = nil
  @Binding var showSignInView: Bool
  @Binding var userIsLoggedIn: Bool
  
  var body: some View {
    NavigationStack {
      List(viewModel.categories, id: \.id) { category in
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
      .padding(.top, -8)
      .navigationTitle("Business Directory")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        viewModel.loadCategories()
      }
    }
    .customNavigationBar(showSignInView: $showSignInView, isLoggedIn: $userIsLoggedIn)
  }
}

#Preview {
  DirectoryListView(showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}
