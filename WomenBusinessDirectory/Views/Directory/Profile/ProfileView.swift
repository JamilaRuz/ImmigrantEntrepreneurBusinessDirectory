import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var entrepreneur: Entrepreneur
    @Published var companies: [Company] = []
    @Published private(set) var allCategories: [Category] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // Use a task manager to ensure we can cancel in-flight operations
    private var loadTask: Task<Void, Never>?
    
    init() {
        self.entrepreneur = Entrepreneur(entrepId: "", fullName: "", profileUrl: nil, email: "", bioDescr: "", companyIds: [], countryOfOrigin: "")
    }
    
    // Main public interface - cancels any in-flight operations and starts a new load
    @MainActor
    func loadData(for entrepreneurParam: Entrepreneur?) {
        // Cancel any existing load task
        loadTask?.cancel()
        
        // Start a new load task
        loadTask = Task { @MainActor in
            do {
                // Show loading indicator
                self.isLoading = true
                self.errorMessage = nil
                
                // Perform the actual data loading
                try await performDataLoading(for: entrepreneurParam)
            } catch is CancellationError {
                // Task was cancelled, do nothing
                print("Data loading was cancelled")
            } catch {
                // Handle errors
                self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                print("Error loading data: \(error)")
            }
            
            // Always hide loading indicator when done
            self.isLoading = false
        }
    }
    
    @MainActor
    private func performDataLoading(for entrepreneurParam: Entrepreneur?) async throws {
        // STEP 1: Determine and load the entrepreneur
        let loadedEntrepreneur: Entrepreneur
        
        if let entrepreneurParam = entrepreneurParam {
            // Use the provided entrepreneur directly
            loadedEntrepreneur = entrepreneurParam
        } else {
            // Load the current user's entrepreneur data
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            loadedEntrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: authDataResult.uid)
        }
        
        // Check for cancellation before proceeding
        try Task.checkCancellation()
        
        // Update the entrepreneur on the main actor
        self.entrepreneur = loadedEntrepreneur
        
        // STEP 2: Prepare for concurrent operations by extracting necessary data
        let companyIds = loadedEntrepreneur.companyIds
        
        // STEP 3: Load companies and categories concurrently
        let newCompanies = try await loadCompanies(from: companyIds)
        let newCategories = try await loadCategories()
        
        // Check for cancellation before updating UI
        try Task.checkCancellation()
        
        // STEP 4: Update the published properties on the main actor
        self.companies = newCompanies
        self.allCategories = newCategories
    }
    
    // Helper method to load companies
    private func loadCompanies(from companyIds: [String]) async throws -> [Company] {
        if companyIds.isEmpty {
            return []
        }
        
        return try await withThrowingTaskGroup(of: Company.self) { group in
            // Add a task for each company ID
            for companyId in companyIds {
                group.addTask {
                    try await RealCompanyManager.shared.getCompany(companyId: companyId)
                }
            }
            
            // Collect results
            var results: [Company] = []
            for try await company in group {
                results.append(company)
            }
            
            return results
        }
    }
    
    // Helper method to load categories
    private func loadCategories() async throws -> [Category] {
        return try await CategoryManager.shared.getCategories()
    }
    
    // Delete a company and reload data
    func deleteCompany(_ company: Company) async throws {
        // Cancel any in-flight load operations
        loadTask?.cancel()
        
        // Set loading state
        isLoading = true
        
        // Use defer to ensure loading state is reset regardless of success/failure
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
        
        do {
            // Delete from CompanyManager
            try await RealCompanyManager.shared.deleteCompany(companyId: company.companyId)
            
            // Remove from entrepreneur's company list
            try await EntrepreneurManager.shared.removeCompany(companyId: company.companyId)
            
            // Reload all data to ensure consistency
            try await performDataLoading(for: nil)
        } catch {
            self.errorMessage = "Failed to delete company: \(error.localizedDescription)"
            throw error
        }
    }
    
    // Helper method for getting category names
    func getCategoryNames(for company: Company) -> String {
        let names = company.categoryIds.compactMap { categoryId in
            allCategories.first(where: { $0.id == categoryId })?.name
        }
        return names.joined(separator: ", ")
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var completionManager = ProfileCompletionManager.shared
    @State private var showingEditProfile = false
    @State private var showSettingsView = false
    @State private var showingDeleteAlert = false
    @State private var selectedCompanyToEdit: Company?
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    @Environment(\.colorScheme) private var colorScheme
    let isEditable: Bool
    let entrepreneur: Entrepreneur?
    
    // Computed property to determine if this is the current user's profile
    private var isOwnProfile: Bool {
        return entrepreneur == nil
    }
    
    init(showSignInView: Binding<Bool>, userIsLoggedIn: Binding<Bool>, isEditable: Bool = true, entrepreneur: Entrepreneur? = nil) {
        self._showSignInView = showSignInView
        self._userIsLoggedIn = userIsLoggedIn
        self.isEditable = isEditable
        self.entrepreneur = entrepreneur
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.bottom)

                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            profileCard
                            entrepreneurStory
                            
                            // Add a clear heading for the businesses section
                            Text("Businesses & Services")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.purple1)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 10)
                            
                            companiesList
                                .onAppear() {
                                    viewModel.loadData(for: entrepreneur)
                                }
                        }
                        .padding()
                    }
                    
                    if isEditable {
                        addCompanyButton
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .modifier(CustomNavigationBarModifier(isOwnProfile: isOwnProfile, showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn))
            .withProfileCompletionBanner(isOwnProfile: isOwnProfile, action: {
                showingEditProfile = true
            })
        }
//        .task {
//            viewModel.loadData(for: entrepreneur)
//            if isEditable && isOwnProfile {
//                await MainActor.run {
//                    completionManager.checkProfileCompletion()
//                }
//            }
//        }
        .onAppear {
            // Reload data when view appears
            viewModel.loadData(for: entrepreneur)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(entrepreneur: viewModel.entrepreneur) {
                // Refresh data when edit view saves changes
                viewModel.loadData(for: entrepreneur)
                Task { @MainActor in
                    if isEditable && isOwnProfile {
                        await completionManager.checkProfileCompletion()
                    }
                }
            }
        }
    }
    
    private var profileCard: some View {
        HStack(spacing: 15) {
            // Profile image with edit button overlay
            ZStack(alignment: .topTrailing) {
                if let profileUrl = viewModel.entrepreneur.profileUrl,
                   !profileUrl.isEmpty,
                   let url = URL(string: profileUrl) {
                    CachedAsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            DefaultProfileImage(size: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        case .failure:
                            DefaultProfileImage(size: 120)
                        }
                    }
                } else {
                    DefaultProfileImage(size: 120)
                }
                
                if isEditable {
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .padding(6)
                            .foregroundColor(.white)
                            .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.purple1)
                            .clipShape(Circle())
                    }
                    .offset(x: 5, y: -5)
                }
            }
            
            // Name, email, and country
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.entrepreneur.fullName ?? "Entrepreneur Name")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(viewModel.entrepreneur.email ?? "email@example.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Country of origin with flag
                if let country = viewModel.entrepreneur.countryOfOrigin, !country.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundColor(.purple1)
                        
                        Text(country)
                            .font(.subheadline)
                            .foregroundColor(.purple1)
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
    
    private var entrepreneurStory: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Entrepreneur's Story")
                .font(.title2)
                .italic()
                .foregroundColor(.purple1)
            
            if let bio = viewModel.entrepreneur.bioDescr, !bio.isEmpty {
                ExpandableTextView(text: bio, color: .purple1)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.purple1.opacity(0.6))
                    
                    Text("Share your entrepreneurial journey here! Tell us about your passion, vision, and what inspired you to start your business. Your story can inspire others...")
                        .font(.subheadline)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    if isEditable {
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Add Your Story")
                                .font(.subheadline)
                                .foregroundColor(colorScheme == .dark ? Color.white : .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.purple1)
                                .cornerRadius(20)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.purple1.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var companiesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.companies.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "building.2")
                        .font(.system(size: 50))
                        .foregroundColor(.pink1.opacity(0.6))
                    
                    Text("No services or businesses to show")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add your business or services that you provide as an entrepreneur to showcase to potential customers.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.pink1.opacity(0.05))
                .cornerRadius(12)
            } else {
                ForEach(viewModel.companies, id: \.self) { company in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink {
                            CompanyDetailView(company: company)
                        } label: {
                            CompanyRowView(company: company, categories: viewModel.allCategories)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isEditable {
                            // Action buttons
                            HStack(spacing: 16) {
                                NavigationLink {
                                    AddCompanyView(
                                        viewModel: AddCompanyViewModel(),
                                        entrepreneur: viewModel.entrepreneur,
                                        editingCompany: company
                                    )
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(colorScheme == .dark ? .white : .purple1)
                                        .padding(8)
                                        .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                
                                Button {
                                    selectedCompanyToEdit = company
                                    showingDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                            }
                            .offset(x: 10, y: -10)
                        }
                    }
                }
            }
        }
        .alert("Delete Company", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let company = selectedCompanyToEdit {
                    Task {
                        do {
                            try await viewModel.deleteCompany(company)
                        } catch {
                            print("Failed to delete company: \(error)")
                        }
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this company? This action cannot be undone.")
        }
    }
    
    private var addCompanyButton: some View {
        NavigationLink(
            destination: AddCompanyView(
                viewModel: AddCompanyViewModel(),
                entrepreneur: viewModel.entrepreneur
            )
        ) {
            Text("Add Business/Service")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(colorScheme == .dark ? .white : .pink1)
                .frame(width: 180, height: 40)
                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.pink1.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}

struct CustomNavigationBarModifier: ViewModifier {
    let isOwnProfile: Bool
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    
    func body(content: Content) -> some View {
        if isOwnProfile {
            content.customNavigationBar(
                showSignInView: $showSignInView,
                isLoggedIn: $userIsLoggedIn
            )
        } else {
            content
        }
    }
}

struct ExpandableTextView: View {
    let text: String
    let color: Color
    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var lineLimit = 4
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(color)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Detect if text is truncated
                    GeometryReader { geometry in
                        ZStack {
                            // Create two text views to compare their heights
                            Text(text)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .hidden()
                                .background(
                                    GeometryReader { fullTextGeometry in
                                        Color.clear.onAppear {
                                            // Compare the height of truncated vs full text
                                            let truncated = fullTextGeometry.size.height > geometry.size.height
                                            DispatchQueue.main.async {
                                                isTruncated = truncated
                                            }
                                        }
                                    }
                                )
                        }
                    }
                )
            
            if isTruncated && !isExpanded {
                Button(action: {
                    isExpanded = true
                }) {
                    Text("more...")
                        .font(.subheadline)
                        .foregroundColor(color)
                        .underline()
                }
            }
        }
        .sheet(isPresented: $isExpanded) {
            ZStack {
                // Background that matches the parent view's color scheme
                (colorScheme == .dark ? Color.black : Color(.systemGray6))
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        Text("Tell us about yourself")
                            .font(.title2)
                            .italic()
                            .foregroundColor(.purple1)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text(text)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(color)
                            .lineSpacing(8)
                        
                        Spacer()
                    }
                    .padding(24)
                }
                .overlay(
                    Button(action: {
                        isExpanded = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                            .padding()
                    }, alignment: .topTrailing
                )
            }
        }
    }
}
