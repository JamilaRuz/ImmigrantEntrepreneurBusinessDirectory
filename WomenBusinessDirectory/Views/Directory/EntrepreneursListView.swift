import SwiftUI
import FirebaseFirestore

@MainActor
final class EntrepreneursListViewModel: ObservableObject {
    @Published private(set) var entrepreneurs: [Entrepreneur] = []
    @Published private(set) var entrepreneurCompanies: [String: [Company]] = [:]
    @Published var searchTerm = ""
    @Published var isLoading = true
    @Published var error: String?
    @Published var cacheStats: String = ""
    
    var filteredEntrepreneurs: [Entrepreneur] {
        if searchTerm.isEmpty {
            return entrepreneurs
        }
        return entrepreneurs.filter { entrepreneur in
            let name = entrepreneur.fullName?.lowercased() ?? ""
            let bio = entrepreneur.bioDescr?.lowercased() ?? ""
            let companies = entrepreneurCompanies[entrepreneur.entrepId]?.map { $0.name.lowercased() } ?? []
            let searchLower = searchTerm.lowercased()
            
            return name.contains(searchLower) || 
                   bio.contains(searchLower) ||
                   companies.contains { $0.contains(searchLower) }
        }
    }
    
    func loadEntrepreneurs() {
        Task {
            do {
                isLoading = true
                error = nil
                
                self.entrepreneurs = try await EntrepreneurManager.shared.getAllEntrepreneurs()
                
                // Load companies for each entrepreneur
                for entrepreneur in entrepreneurs {
                    let companies = try await entrepreneur.companyIds.asyncMap { companyId in
                        try await RealCompanyManager.shared.getCompany(companyId: companyId)
                    }
                    entrepreneurCompanies[entrepreneur.entrepId] = companies
                }
                
                isLoading = false
            } catch {
                self.error = "Failed to load entrepreneurs: \(error.localizedDescription)"
                isLoading = false
                print("Error loading entrepreneurs: \(error)")
            }
        }
    }
    
    func getCompanies(for entrepreneur: Entrepreneur) -> [Company] {
        return entrepreneurCompanies[entrepreneur.entrepId] ?? []
    }
    
    func updateCacheStats() {
        cacheStats = ImageCache.shared.getCacheStats()
    }
    
    func clearImageCache() {
        ImageCache.shared.clearCache()
        updateCacheStats()
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
    @State private var showCacheStats = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchTerm)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                
                // Debug cache info (only in DEBUG mode)
                #if DEBUG
                if showCacheStats {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cache Statistics")
                            .font(.headline)
                        
                        Text(viewModel.cacheStats)
                            .font(.caption)
                        
                        HStack {
                            Button("Refresh Stats") {
                                viewModel.updateCacheStats()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Clear Cache") {
                                viewModel.clearImageCache()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                #endif
                
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
                        if viewModel.searchTerm.isEmpty {
                            Text("No entrepreneurs found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.orange1)
                        } else {
                            Text("No entrepreneurs match your search")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.orange1)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(viewModel.filteredEntrepreneurs, id: \.entrepId) { entrepreneur in
                            NavigationLink(destination: ProfileView(showSignInView: .constant(false), isEditable: false, entrepreneur: entrepreneur)) {
                                EntrepreneurRowView(entrepreneur: entrepreneur, viewModel: viewModel)
                            }
                            .listRowSeparator(.visible)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await Task { 
                            viewModel.loadEntrepreneurs() 
                        }.value
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Entrepreneurs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCacheStats.toggle()
                        if showCacheStats {
                            viewModel.updateCacheStats()
                        }
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
                #endif
            }
        }
        .tint(Color.orange1)
        .task {
            viewModel.loadEntrepreneurs()
        }
    }
}

#Preview {
    EntrepreneursListView()
} 