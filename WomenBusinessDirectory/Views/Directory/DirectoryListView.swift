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
  @Published var isLoading = false
  private var hasInitialLoad = false
  
  private let filterManager: FilterManaging
  private var notificationObserver: NSObjectProtocol?
  
  // Add a flag to track if the view is active
  private var isViewActive = false
  
  var activeFiltersCount: Int {
    let selectedCities = filterManager.getSelectedCities().count
    let selectedOwnershipTypes = filterManager.getSelectedOwnershipTypes().count
    return selectedCities + selectedOwnershipTypes
  }
  
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
  
  func setViewActive(_ active: Bool) {
    isViewActive = active
    if active && !isLoading && (categories.isEmpty || allCompanies.isEmpty) {
      loadData()
    }
  }
  
  func loadData() {
    // Skip loading if the view is not active
    if !isViewActive {
      print("DirectoryListView: View is not active, skipping load...")
      return
    }
    
    // Only check if already loading after initial load
    if isLoading {
      print("DirectoryListView: Already loading data, skipping redundant load...")
      return
    }
    
    Task {
      do {
        print("DirectoryListView: Starting to load data...")
        isLoading = true
        
        // Load all data concurrently
        async let categoriesTask = CategoryManager.shared.getCategories()
        async let companiesTask = RealCompanyManager.shared.getCompanies()
        
        self.categories = try await categoriesTask
        self.allCompanies = try await companiesTask
        hasInitialLoad = true
        isLoading = false
      } catch {
        print("DirectoryListView: Failed to load data: \(error)")
        isLoading = false
      }
    }
  }
  
  // Add a method to force reload data even if isLoading is true
  func forceReload() {
    print("DirectoryListView: Force reloading data...")
    // Reset loading state
    isLoading = false
    // Call loadData with force refresh
    Task {
      do {
        print("DirectoryListView: Starting to force reload data...")
        isLoading = true
        
        // Load all data concurrently with cache policy to fetch from server
        async let categoriesTask = CategoryManager.shared.getCategories()
        async let companiesTask = RealCompanyManager.shared.getCompanies(source: .server)
        
        self.categories = try await categoriesTask
        self.allCompanies = try await companiesTask
        hasInitialLoad = true
        isLoading = false
        print("DirectoryListView: Finished force reloading data")
      } catch {
        print("DirectoryListView: Failed to force reload data: \(error)")
        isLoading = false
      }
    }
  }
}

struct DirectoryListView: View {
  @ObservedObject var viewModel: DirectoryListViewModel
  @Binding var showSignInView: Bool
  @Binding var userIsLoggedIn: Bool
  @State private var showFilterSheet = false
  @State private var showToast = false
  @State private var showDeleteConfirmation = false
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        if viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          List(viewModel.filteredCompaniesByCategory, id: \.category.id) { categoryData in
            NavigationLink(destination: CompaniesListView(category: categoryData.category)) {
              HStack(spacing: 12) {
                Image(systemName: categoryData.category.systemIconName)
                  .foregroundColor(Color.purple1)
                  .frame(width: 28, height: 28)
                
                Text(categoryData.category.name)
                  .font(.system(size: 15))
                
                Spacer()
                
                if categoryData.count > 0 {
                  Text("\(categoryData.count)")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
                }
              }
              .padding(.vertical, 12)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
          }
          .listStyle(.automatic)
          .background(Color.white)
          .refreshable {
            viewModel.forceReload()
          }
        }
      }
      .navigationTitle("Business Directory")
      .navigationBarTitleDisplayMode(.inline)
      .customNavigationBar(
        showSignInView: $showSignInView,
        isLoggedIn: $userIsLoggedIn,
        activeFiltersCount: viewModel.activeFiltersCount
      )
      .onAppear {
        viewModel.setViewActive(true)
      }
      .onDisappear {
        viewModel.setViewActive(false)
      }
    }
    .alert("Delete Account", isPresented: $showDeleteConfirmation) {
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) {
        // Handle account deletion
      }
    } message: {
      Text("Are you sure you want to delete your account? This will permanently delete all your data including your profile, companies, and all associated images. This action cannot be undone.")
    }
  }
}

#Preview {
  DirectoryListView(viewModel: DirectoryListViewModel(), showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}
