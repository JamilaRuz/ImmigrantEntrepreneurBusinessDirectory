import SwiftUI

@MainActor
final class CompaniesListViewModel: ObservableObject {
    @Published private(set) var companies: [Company] = []
    @Published private(set) var categories: [Category] = []
    @Published var isLoading = true
    @Published var searchTerm = ""
    
    private let category: Category
    private let filterManager: FilterManaging
    
    init(category: Category, filterManager: FilterManaging = FilterManager.shared) {
        self.category = category
        self.filterManager = filterManager
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
        
        return filtered
    }
    
    func loadCompanies() {
        Task {
            do {
                isLoading = true
                
                async let companiesTask = RealCompanyManager.shared.getCompaniesByCategory(categoryId: category.id)
                async let categoriesTask = CategoryManager.shared.getCategories()
                
                self.companies = try await companiesTask
                self.categories = try await categoriesTask
                
                isLoading = false
            } catch {
                print("CompaniesListViewModel: Failed to load companies: \(error)")
                isLoading = false
            }
        }
    }
}

struct CompaniesListView: View {
    @StateObject private var viewModel: CompaniesListViewModel
    let category: Category
    
    init(category: Category) {
        self.category = category
        self._viewModel = StateObject(wrappedValue: CompaniesListViewModel(category: category))
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
                            viewModel.loadCompanies()
                        }
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadCompanies()
        }
    }
}


#Preview {
    NavigationStack {
        CompaniesListView(category: Category(id: "1", name: "Test Category", systemIconName: "star"))
    }
} 
