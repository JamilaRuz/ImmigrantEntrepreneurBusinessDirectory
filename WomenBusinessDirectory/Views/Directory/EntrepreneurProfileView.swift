import SwiftUI
import FirebaseFirestoreSwift

@MainActor
final class EntrepreneurProfileViewModel: ObservableObject {
    @Published private(set) var companies: [Company] = []
    @Published private(set) var allCategories: [Category] = []
    let entrepreneur: Entrepreneur
    
    init(entrepreneur: Entrepreneur) {
        self.entrepreneur = entrepreneur
    }
    
    func loadData() async throws {
        async let companiesTask = loadCompaniesOfEntrepreneur()
        async let categoriesTask = loadAllCategories()
        
        self.companies = try await companiesTask
        self.allCategories = try await categoriesTask
    }
    
    private func loadCompaniesOfEntrepreneur() async throws -> [Company] {
        return try await entrepreneur.companyIds.asyncMap { companyId in
            try await RealCompanyManager.shared.getCompany(companyId: companyId)
        }
    }
    
    private func loadAllCategories() async throws -> [Category] {
        return try await CategoryManager.shared.getCategories()
    }
}

struct EntrepreneurProfileView: View {
    let entrepreneur: Entrepreneur
    @StateObject private var viewModel: EntrepreneurProfileViewModel
    
    init(entrepreneur: Entrepreneur) {
        self.entrepreneur = entrepreneur
        self._viewModel = StateObject(wrappedValue: EntrepreneurProfileViewModel(entrepreneur: entrepreneur))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Card
                VStack(alignment: .center, spacing: 10) {
                    if let profileUrlString = entrepreneur.profileUrl,
                       let profileUrl = URL(string: profileUrlString) {
                        AsyncImage(url: profileUrl) { phase in
                            switch phase {
                            case .empty:
                                Image("placeholder")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                ProgressView()
                                    .frame(width: 100, height: 100)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                
                            case .failure:
                                Image("placeholder")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .scaledToFill()
                                    .background(Color.gray.opacity(0.5))
                                    .clipShape(Circle())
                            @unknown default:
                                Image("placeholder")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                    
                    Text(entrepreneur.fullName ?? "Entrepreneur Name")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(entrepreneur.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Entrepreneur's Story
                VStack(alignment: .center) {
                    Text("Entrepreneur's Story")
                        .font(.custom("Zapfino", size: 24))
                        .foregroundColor(.purple1)
                    
                    Text(entrepreneur.bioDescr ?? "No story shared yet.")
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .foregroundColor(.purple1)
                
                // Companies List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Companies")
                        .font(.headline)
                    
                    if viewModel.companies.isEmpty {
                        Text("No companies to show")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(viewModel.companies, id: \.self) { company in
                            NavigationLink {
                                CompanyDetailView(company: company)
                            } label: {
                                CompanyRowView(company: company, categories: viewModel.allCategories)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple1.opacity(0.1),
                    Color.pink1.opacity(0.1),
                    Color.white.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Entrepreneur Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                try await viewModel.loadData()
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        EntrepreneurProfileView(
            entrepreneur: Entrepreneur(
                entrepId: "1",
                fullName: "Test Entrepreneur",
                profileUrl: nil,
                email: "test@example.com",
                bioDescr: "This is a test bio",
                companyIds: []
            )
        )
    }
} 