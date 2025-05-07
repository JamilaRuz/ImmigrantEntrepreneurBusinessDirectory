import SwiftUI
import FirebaseFirestore

@MainActor
final class EntrepreneursListViewModel: ObservableObject {
    @Published private(set) var entrepreneurs: [Entrepreneur] = []
    @Published private(set) var entrepreneurCompanies: [String: [Company]] = [:]
    @Published var searchTerm = ""
    @Published var selectedCountry: String? = nil
    @Published var isLoading = true
    @Published var error: String?
    @Published var availableCountries: [String] = []
    
    private let filterManager: FilterManaging
    
    init(filterManager: FilterManaging? = nil) {
        // Use the passed filterManager or get it on the main actor
        self.filterManager = filterManager ?? FilterManager.shared
        
        // Load entrepreneurs
        loadEntrepreneurs()
    }
    
    var filteredEntrepreneurs: [Entrepreneur] {
        // First filter out entrepreneurs with incomplete profiles
        let completedEntrepreneurs = entrepreneurs.filter { entrepreneur in
            // Check if profile has basic information
            let hasName = (entrepreneur.fullName?.isEmpty == false)
            let hasBio = (entrepreneur.bioDescr?.isEmpty == false)
            let hasProfileImage = (entrepreneur.profileUrl?.isEmpty == false)
            let hasCompanies = !entrepreneur.companyIds.isEmpty
            
            // Profile is complete if it has name, either bio or profile image, and at least one company
            return hasName && (hasBio || hasProfileImage) && hasCompanies
        }
        
        // Apply country filter if selected in the FilterManager
        let selectedCountries = filterManager.getSelectedCountries()
        let countryFiltered = selectedCountries.isEmpty
            ? completedEntrepreneurs 
            : completedEntrepreneurs.filter { 
                // If entrepreneur has a country of origin, check if it's in the selected countries
                guard let country = $0.countryOfOrigin, !country.isEmpty else {
                    return false
                }
                return selectedCountries.contains(country)
            }
            
        // Also apply individual view's selected country filter if set
        let viewFilteredEntrepreneurs = selectedCountry == nil 
            ? countryFiltered 
            : countryFiltered.filter { $0.countryOfOrigin == selectedCountry }
        
        // Then apply search filter
        if searchTerm.isEmpty {
            return viewFilteredEntrepreneurs
        }
        return viewFilteredEntrepreneurs.filter { entrepreneur in
            let name = entrepreneur.fullName?.lowercased() ?? ""
            let bio = entrepreneur.bioDescr?.lowercased() ?? ""
            let companies = entrepreneurCompanies[entrepreneur.entrepId]?.map { $0.name.lowercased() } ?? []
            let country = entrepreneur.countryOfOrigin?.lowercased() ?? ""
            let searchLower = searchTerm.lowercased()
            
            return name.contains(searchLower) || 
                   bio.contains(searchLower) ||
                   country.contains(searchLower) ||
                   companies.contains { $0.contains(searchLower) }
        }
    }
    
    func loadEntrepreneurs() {
        Task {
            do {
                isLoading = true
                error = nil
                
                print("EntrepreneursListViewModel: Loading entrepreneurs...")
                self.entrepreneurs = try await EntrepreneurManager.shared.getAllEntrepreneurs()
                print("EntrepreneursListViewModel: Successfully loaded \(entrepreneurs.count) entrepreneurs")
                
                // Extract all unique countries
                let countries = entrepreneurs.compactMap { $0.countryOfOrigin }
                    .filter { !$0.isEmpty }
                self.availableCountries = Array(Set(countries)).sorted()
                
                // Send countries to FilterManager for the filter view
                await updateAvailableCountriesInFilterManager()
                
                // Load companies for each entrepreneur
                for entrepreneur in entrepreneurs {
                    print("EntrepreneursListViewModel: Loading companies for entrepreneur: \(entrepreneur.entrepId)")
                    do {
                        let companies = try await entrepreneur.companyIds.asyncMap { companyId in
                            try await RealCompanyManager.shared.getCompany(companyId: companyId)
                        }
                        entrepreneurCompanies[entrepreneur.entrepId] = companies
                        print("EntrepreneursListViewModel: Loaded \(companies.count) companies for entrepreneur: \(entrepreneur.entrepId)")
                    } catch {
                        print("EntrepreneursListViewModel: Error loading companies for entrepreneur \(entrepreneur.entrepId): \(error)")
                        // Continue with other entrepreneurs even if one fails
                        entrepreneurCompanies[entrepreneur.entrepId] = []
                    }
                }
                
                isLoading = false
            } catch {
                self.error = "Failed to load entrepreneurs: \(error.localizedDescription)"
                isLoading = false
                print("Error loading entrepreneurs: \(error)")
            }
        }
    }
    
    // New function to update available countries in the FilterManager
    private func updateAvailableCountriesInFilterManager() async {
        do {
            try await filterManager.setAvailableCountries(availableCountries)
        } catch {
            print("Error updating available countries in FilterManager: \(error)")
        }
    }
    
    func getCompanies(for entrepreneur: Entrepreneur) -> [Company] {
        return entrepreneurCompanies[entrepreneur.entrepId] ?? []
    }
}

struct EntrepreneurRowView: View {
    let entrepreneur: Entrepreneur
    @ObservedObject var viewModel: EntrepreneursListViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let profileUrlString = entrepreneur.profileUrl,
               let profileUrl = URL(string: profileUrlString) {
                CachedAsyncImage(url: profileUrl) { phase in
                    switch phase {
                    case .empty:
                        DefaultProfileImage(size: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    case .failure:
                        DefaultProfileImage(size: 50)
                    }
                }
                .frame(width: 50, height: 50)
            } else {
                DefaultProfileImage(size: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Name and email
                Text(entrepreneur.fullName ?? "Entrepreneur")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let email = entrepreneur.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Country of origin if available
                if let country = entrepreneur.countryOfOrigin, !country.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.caption2)
                        Text(country)
                            .font(.caption)
                    }
                    .foregroundColor(.orange1)
                }
                
                // Company names or placeholder
                let companies = viewModel.getCompanies(for: entrepreneur)
                if !companies.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(companies, id: \.companyId) { company in
                                HStack(spacing: 4) {
                                    CachedAsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                                        switch phase {
                                        case .empty, .failure:
                                            Image(systemName: "building.2.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(.gray.opacity(0.5))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 16, height: 16)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .frame(width: 16, height: 16)
                                    
                                    Text(company.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange1.opacity(0.1))
                                .foregroundColor(Color.orange1)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 28)
                } else {
                    Text("No companies added yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct EntrepreneursListView: View {
    @StateObject private var viewModel = EntrepreneursListViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    @State private var showCountryFilter = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                HStack {
                    // Search Field
                    SearchBar(text: $viewModel.searchTerm)
                        .frame(maxWidth: .infinity)
                    
                    // Country Filter Button
                    Button(action: {
                        showCountryFilter = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            if let country = viewModel.selectedCountry {
                                Text(country)
                                    .lineLimit(1)
                            }
                        }
                        .padding(8)
                        .background(viewModel.selectedCountry != nil ? Color.orange1.opacity(0.2) : Color(.systemGray6))
                        .foregroundColor(viewModel.selectedCountry != nil ? .orange1 : .gray)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Active Filter Indicator
                if viewModel.selectedCountry != nil {
                    HStack {
                        Text("Filtered by: \(viewModel.selectedCountry ?? "")")
                            .font(.caption)
                            .foregroundColor(.orange1)
                        
                        Button(action: {
                            viewModel.selectedCountry = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.orange1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Color.orange1)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredEntrepreneurs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 70))
                            .foregroundColor(Color.orange1)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.orange1.opacity(0.1))
                                    .frame(width: 120, height: 120)
                            )
                        if viewModel.searchTerm.isEmpty && viewModel.selectedCountry == nil {
                            Text("No entrepreneurs found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.orange1)
                            
                            Text("Only entrepreneurs with complete profiles are shown in the directory")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            Text("No entrepreneurs match your filters")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.orange1)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredEntrepreneurs, id: \.entrepId) { entrepreneur in
                            NavigationLink(destination: ProfileView(showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn, isEditable: false, entrepreneur: entrepreneur)) {
                                EntrepreneurRowView(entrepreneur: entrepreneur, viewModel: viewModel)
                            }
                            .listRowSeparator(.visible)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.automatic)
                    .background(Color.white)
                    .refreshable {
                        await Task { 
                            viewModel.loadEntrepreneurs() 
                        }.value
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Entrepreneurs")
            .navigationBarTitleDisplayMode(.inline)
            .customNavigationBar(
                showSignInView: $showSignInView,
                isLoggedIn: $userIsLoggedIn
            )
            .sheet(isPresented: $showCountryFilter) {
                CountryFilterView(
                    selectedCountry: $viewModel.selectedCountry,
                    availableCountries: viewModel.availableCountries
                )
            }
        }
        .tint(Color.orange1)
        .task {
            viewModel.loadEntrepreneurs()
            
            // Update login status
            if let _ = try? AuthenticationManager.shared.getAuthenticatedUser() {
                userIsLoggedIn = true
            }
        }
    }
}

#Preview {
    EntrepreneursListView(showSignInView: .constant(false), userIsLoggedIn: .constant(false))
} 
