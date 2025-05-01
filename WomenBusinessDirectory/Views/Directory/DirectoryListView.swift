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
  
  init(filterManager: FilterManaging? = nil) {
    // Use the passed filterManager or get it on the main actor
    self.filterManager = filterManager ?? FilterManager.shared
    
    // Observe UserDefaults changes for filters
    notificationObserver = NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        await self?.loadData()
      }
    }
  }
  
  deinit {
    if let observer = notificationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
  var filteredCompaniesByCategory: [(category: Category, count: Int)] {
    var filtered = allCompanies
    
    // Apply city filter if cities are selected
    let selectedCities = filterManager.getSelectedCities()
    if !selectedCities.isEmpty {
      // Standardize the selected cities
      let standardizedSelectedCities = Set(selectedCities.map { filterManager.standardizeCity($0) })
      
      filtered = filtered.filter { company in
        // Standardize company city before comparison
        let standardizedCompanyCity = filterManager.standardizeCity(company.city)
        return standardizedSelectedCities.contains(standardizedCompanyCity)
      }
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
      Task { @MainActor in
        await loadData()
      }
    }
  }
  
  func loadData() async {
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
  
  // Add a method to force reload data even if isLoading is true
  func forceReload() {
    print("DirectoryListView: Force reloading data...")
    // Reset loading state
    isLoading = false
    // Call loadData with force refresh
    Task { @MainActor in
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
  @StateObject private var viewModel: DirectoryListViewModel
  @Binding var showSignInView: Bool
  @Binding var userIsLoggedIn: Bool
  @State private var showFilterSheet = false
  @State private var showToast = false
  @State private var showDeleteConfirmation = false
  
  init(showSignInView: Binding<Bool>, userIsLoggedIn: Binding<Bool>) {
    self._showSignInView = showSignInView
    self._userIsLoggedIn = userIsLoggedIn
    
    // Get filter manager on the main thread
    let filterManager = FilterManager.shared
    self._viewModel = StateObject(wrappedValue: DirectoryListViewModel(filterManager: filterManager))
  }
  
  // Preview initializer
  init(viewModel: DirectoryListViewModel, showSignInView: Binding<Bool>, userIsLoggedIn: Binding<Bool>) {
    self._viewModel = StateObject(wrappedValue: viewModel)
    self._showSignInView = showSignInView
    self._userIsLoggedIn = userIsLoggedIn
  }
  
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
      .navigationTitle("Find a Business")
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
  }
}

#Preview {
  let viewModel = DirectoryListViewModel()
  return DirectoryListView(viewModel: viewModel, showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}
