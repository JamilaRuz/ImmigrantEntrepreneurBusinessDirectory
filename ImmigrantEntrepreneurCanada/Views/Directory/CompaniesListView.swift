import SwiftUI

@MainActor
final class CompaniesListViewModel: ObservableObject {
    @Published private(set) var companies: [Company] = []
    @Published private(set) var categories: [Category] = []
    @Published var isLoading = false
    @Published var searchTerm = ""
    
    private let category: Category
    private let filterManager: FilterManaging
    
    // Add a flag to track if the view is active
    private var isViewActive = false
    
    init(category: Category, filterManager: FilterManaging? = nil) {
        self.category = category
        // Use the passed filterManager or get it on the main actor
        self.filterManager = filterManager ?? FilterManager.shared
    }
    
    var filteredCompanies: [Company] {
        var filtered = companies
        
        // Apply search filter
        if !searchTerm.isEmpty {
            filtered = filtered.filter { company in
                company.name.localizedCaseInsensitiveContains(searchTerm) ||
                company.aboutUs.localizedCaseInsensitiveContains(searchTerm)
            }
        }
        
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
        
        return filtered
    }
    
    func setViewActive(_ active: Bool) {
        isViewActive = active
        if active && !isLoading && companies.isEmpty {
            loadCompanies()
        }
    }
    
    func loadCompanies() {
        // Skip loading if the view is not active
        if !isViewActive {
            print("CompaniesListViewModel: View is not active, skipping load...")
            return
        }
        
        // Only check if already loading
        if isLoading {
            print("CompaniesListViewModel: Already loading companies, skipping redundant load...")
            return
        }
        
        Task {
            do {
                isLoading = true
                print("CompaniesListViewModel: Loading companies for category \(category.id)...")
                
                async let companiesTask = RealCompanyManager.shared.getCompaniesByCategory(categoryId: category.id)
                async let categoriesTask = CategoryManager.shared.getCategories()
                
                self.companies = try await companiesTask
                self.categories = try await categoriesTask
                
                isLoading = false
                print("CompaniesListViewModel: Finished loading \(self.companies.count) companies")
            } catch {
                print("CompaniesListViewModel: Failed to load companies: \(error)")
                isLoading = false
            }
        }
    }
    
    // Add a method to force reload data from server
    func forceReload() {
        print("CompaniesListViewModel: Force reloading companies from server...")
        
        Task {
            do {
                isLoading = true
                print("CompaniesListViewModel: Loading companies for category \(category.id) from server...")
                
                async let companiesTask = RealCompanyManager.shared.getCompaniesByCategory(categoryId: category.id, source: .server)
                async let categoriesTask = CategoryManager.shared.getCategories()
                
                self.companies = try await companiesTask
                self.categories = try await categoriesTask
                
                isLoading = false
                print("CompaniesListViewModel: Finished loading \(self.companies.count) companies from server")
            } catch {
                print("CompaniesListViewModel: Failed to load companies from server: \(error)")
                isLoading = false
            }
        }
    }
}

struct CompaniesListView: View {
    @StateObject private var viewModel: CompaniesListViewModel
    @State private var showSignInView = false
    @State private var userIsLoggedIn = false
    let category: Category
    
    init(category: Category) {
        self.category = category
        
        // Properly handle MainActor isolation
        let filterManager = FilterManager.shared
        self._viewModel = StateObject(wrappedValue: CompaniesListViewModel(category: category, filterManager: filterManager))
        
        // Check if user is logged in
        if let _ = try? AuthenticationManager.shared.getAuthenticatedUser() {
            self._userIsLoggedIn = State(initialValue: true)
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(text: $viewModel.searchTerm)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    if viewModel.filteredCompanies.isEmpty {
                        VStack(spacing: 16) {
                            Text("No Companies Yet")
                                .font(.title2)
                                .foregroundColor(Color.orange1)
                            Text("Companies in this category will appear here once they are added.")
                                .font(.subheadline)
                                .foregroundColor(Color.orange1)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(y: -30)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredCompanies, id: \.companyId) { company in
                                    NavigationLink {
                                        CompanyDetailView(company: company)
                                            .navigationBarTitleDisplayMode(.inline)
                                    } label: {
                                        CompanyRowView(company: company, categories: viewModel.categories)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .scrollContentBackground(.hidden)
                        .refreshable {
                            viewModel.forceReload()
                        }
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setViewActive(true)
            
            // Update login status
            if let _ = try? AuthenticationManager.shared.getAuthenticatedUser() {
                userIsLoggedIn = true
            }
        }
        .onDisappear {
            viewModel.setViewActive(false)
        }
    }
}

#Preview {
    CompaniesListView(category: Category(id: "1", name: "Test Category", systemIconName: "star"))
} 
