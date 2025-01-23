//
//  DirectoryListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI

@MainActor
final class DirectoryListViewModel: ObservableObject {
  @Published private(set) var categoriesWithCount: [(category: Category, count: Int)] = []
  @Published var isLoading = true
  
  private let filterManager: FilterManaging
  private var notificationObserver: NSObjectProtocol?
  
  init(filterManager: FilterManaging = FilterManager.shared) {
    self.filterManager = filterManager
    
    // Observe UserDefaults changes
    notificationObserver = NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.loadCategories()
    }
  }
  
  deinit {
    if let observer = notificationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
  func loadCategories() {
    Task {
      do {
        isLoading = true
        // Get current filter selections
        let selectedCity = filterManager.getSelectedCities().first
        let selectedOwnershipTypes = filterManager.getSelectedOwnershipTypes()
        
        // Get filtered categories with counts
        self.categoriesWithCount = try await CategoryManager.shared.getCategoriesWithCompanyCount(
          selectedCity: selectedCity,
          selectedOwnershipTypes: selectedOwnershipTypes
        )
        isLoading = false
      } catch {
        print("Failed to load categories: \(error)")
        isLoading = false
      }
    }
  }
}

struct DirectoryListView: View {
  @StateObject var viewModel = DirectoryListViewModel()
  @Binding var showSignInView: Bool
  @Binding var userIsLoggedIn: Bool
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        if viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          // Categories List
          List(viewModel.categoriesWithCount, id: \.category.id) { categoryWithCount in
            NavigationLink(destination: CompaniesListView(category: categoryWithCount.category)) {
              HStack {
                Image(systemName: "car.fill")
                  .frame(width: 50, height: 50)
                  .foregroundColor(Color.purple1)
                
                Text(categoryWithCount.category.name)
                  .font(.headline)
                
                Spacer()
                
                Text("\(categoryWithCount.count)")
                  .font(.subheadline)
                  .foregroundColor(.gray)
                  .padding(.horizontal, 12)
                  .padding(.vertical, 4)
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(12)
              }
            }
          }
          .listStyle(PlainListStyle())
          .refreshable {
            viewModel.loadCategories()
          }
        }
      }
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
