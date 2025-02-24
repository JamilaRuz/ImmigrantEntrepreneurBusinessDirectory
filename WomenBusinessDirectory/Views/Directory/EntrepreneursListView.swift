import SwiftUI
import FirebaseFirestore

@MainActor
final class EntrepreneursListViewModel: ObservableObject {
    @Published private(set) var entrepreneurs: [Entrepreneur] = []
    @Published private(set) var entrepreneurCompanies: [String: [Company]] = [:]
    @Published var searchTerm = ""
    @Published var isLoading = true
    @Published var error: String?
    
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
}

struct EntrepreneurRowView: View {
    let entrepreneur: Entrepreneur
    @ObservedObject var viewModel: EntrepreneursListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Profile image
                if let profileUrlString = entrepreneur.profileUrl,
                   let profileUrl = URL(string: profileUrlString) {
                    AsyncImage(url: profileUrl) { phase in
                        switch phase {
                        case .empty:
                            DefaultProfileImage(size: 60)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            DefaultProfileImage(size: 60)
                        @unknown default:
                            DefaultProfileImage(size: 60)
                        }
                    }
                } else {
                    DefaultProfileImage(size: 60)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Name and email
                    Text(entrepreneur.fullName ?? "Entrepreneur")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let email = entrepreneur.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Bio preview or placeholder
                    Text(entrepreneur.bioDescr?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No description available yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Company names or placeholder
            let companies = viewModel.getCompanies(for: entrepreneur)
            VStack(alignment: .leading, spacing: 8) {
                if !companies.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(companies, id: \.companyId) { company in
                                HStack(spacing: 4) {
                                    AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                                        switch phase {
                                        case .empty, .failure:
                                            Image(systemName: "building.2.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.gray.opacity(0.3))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 20, height: 20)
                                                .clipShape(Circle())
                                        @unknown default:
                                            Image(systemName: "building.2.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.gray.opacity(0.3))
                                        }
                                    }
                                    .frame(width: 20, height: 20)
                                    
                                    Text(company.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange1.opacity(0.1))
                                .foregroundColor(Color.orange1)
                                .cornerRadius(8)
                            }
                        }
                    }
                } else {
                    Text("No companies added yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(height: 35) // Fixed height for company section
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct EntrepreneursListView: View {
    @StateObject private var viewModel = EntrepreneursListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Search bar
                    SearchBar(text: $viewModel.searchTerm)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
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
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange1.opacity(0.1),
                                    Color.white
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredEntrepreneurs, id: \.entrepId) { entrepreneur in
                                NavigationLink(destination: ProfileView(showSignInView: .constant(false), isEditable: false, entrepreneur: entrepreneur)) {
                                    EntrepreneurRowView(entrepreneur: entrepreneur, viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Entrepreneurs")
            .navigationBarTitleDisplayMode(.inline)
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