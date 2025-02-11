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
  @Published private(set) var allCompanies: [Company] = []
  @Published var isLoading = true
  
  private let filterManager: FilterManaging
  private var notificationObserver: NSObjectProtocol?
  
  init(filterManager: FilterManaging = FilterManager.shared) {
    self.filterManager = filterManager
    
    // Observe UserDefaults changes for filters
    notificationObserver = NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.loadData()
    }
  }
  
  deinit {
    if let observer = notificationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
  var filteredCompaniesByCategory: [(category: Category, count: Int)] {
    var filtered = allCompanies
    
    // Apply city filter if selected
    if let selectedCity = filterManager.getSelectedCities().first {
      filtered = filtered.filter { $0.city == selectedCity }
    }
    
    // Apply ownership types filter if selected
    let selectedOwnershipTypes = filterManager.getSelectedOwnershipTypes()
    if !selectedOwnershipTypes.isEmpty {
      filtered = filtered.filter { company in
        !Set(company.ownershipTypes).isDisjoint(with: Set(selectedOwnershipTypes))
      }
    }
    
    // Count companies per category
    return categories.map { category in
      let count = filtered.filter { company in
        company.categoryIds.contains(category.id)
      }.count
      return (category: category, count: count)
    }
  }
  
  func loadData() {
    Task {
      do {
        isLoading = true
        
        // Load all data concurrently
        async let categoriesTask = CategoryManager.shared.getCategories()
        async let companiesTask = RealCompanyManager.shared.getCompanies()
        
        self.categories = try await categoriesTask
        self.allCompanies = try await companiesTask
        
        isLoading = false
      } catch {
        print("Failed to load data: \(error)")
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
          List(viewModel.filteredCompaniesByCategory, id: \.category.id) { categoryData in
            NavigationLink(destination: CompaniesListView(category: categoryData.category)) {
              HStack {
                Image(systemName: "building.2.fill")
                  .frame(width: 50, height: 50)
                  .foregroundColor(Color.purple1)
                
                Text(categoryData.category.name)
                  .font(.headline)
                
                Spacer()
                
                Text("\(categoryData.count)")
                  .font(.subheadline)
                  .foregroundColor(.gray)
                  .padding(.horizontal, 12)
                  .padding(.vertical, 4)
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(12)
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
          .refreshable {
            viewModel.loadData()
          }
        }
      }
      .navigationTitle("Business Directory")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        viewModel.loadData()
      }
    }
    .customNavigationBar(showSignInView: $showSignInView, isLoggedIn: $userIsLoggedIn)
  }
}

#Preview {
  DirectoryListView(showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}
