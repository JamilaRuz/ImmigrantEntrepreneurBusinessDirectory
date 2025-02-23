//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var entrepreneur: Entrepreneur
    @Published private(set) var companies: [Company] = []
    @Published private(set) var allCategories: [Category] = []
    
    init() {
        self.entrepreneur = Entrepreneur(entrepId: "", fullName: "", profileUrl: " ", email: "", bioDescr: "", companyIds: [])
    }
    
    func loadData(for entrepreneur: Entrepreneur?) async throws {
        if let entrepreneur = entrepreneur {
            self.entrepreneur = entrepreneur
        }
        try await loadCurrentEntrepreneur()
        async let companiesTask = loadCompaniesOfEntrepreneur()
        async let categoriesTask = loadAllCategories()
        
        self.companies = try await companiesTask
        self.allCategories = try await categoriesTask
    }
    
    private func loadCurrentEntrepreneur() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: authDataResult.uid)
    }
    
    private func loadCompaniesOfEntrepreneur() async throws -> [Company] {
        return try await entrepreneur.companyIds.asyncMap { companyId in
            try await RealCompanyManager.shared.getCompany(companyId: companyId)
        }
    }
    
    private func loadAllCategories() async throws -> [Category] {
        return try await CategoryManager.shared.getCategories()
    }
    
    func getCategoryNames(for company: Company) -> String {
        let names = company.categoryIds.compactMap { categoryId in
            allCategories.first(where: { $0.id == categoryId })?.name
        }
        return names.joined(separator: ", ")
    }
    
    func deleteCompany(_ company: Company) async throws {
        // Delete from CompanyManager
        try await RealCompanyManager.shared.deleteCompany(companyId: company.companyId)
        
        // Remove from entrepreneur's company list
        try await EntrepreneurManager.shared.removeCompany(companyId: company.companyId)
        
        // Reload companies to update the UI
        self.companies = try await loadCompaniesOfEntrepreneur()
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showSettingsView = false
    @State private var showingDeleteAlert = false
    @State private var selectedCompanyToEdit: Company?
    @Binding var showSignInView: Bool
    let isEditable: Bool
    let entrepreneur: Entrepreneur?
    
    init(showSignInView: Binding<Bool>, isEditable: Bool = true, entrepreneur: Entrepreneur? = nil) {
        self._showSignInView = showSignInView
        self.isEditable = isEditable
        self.entrepreneur = entrepreneur
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
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

                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            profileCard
                            entrepreneurStory
                            companiesList
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(isEditable ? "Profile" : "Entrepreneur Profile")
        }
        .task {
            do {
                try await viewModel.loadData(for: entrepreneur)
            } catch {
                print("Failed to load data: \(error)")
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(entrepreneur: viewModel.entrepreneur)
        }
    }
    
    private var profileCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 10) {
                if let profileUrlString = viewModel.entrepreneur.profileUrl, let profileUrl = URL(string: profileUrlString) {
                    AsyncImage(url: profileUrl) { phase in
                        switch phase {
                        case .empty:
                            DefaultProfileImage(size: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure:
                            DefaultProfileImage(size: 100)
                        @unknown default:
                            DefaultProfileImage(size: 100)
                        }
                    }
                    .frame(width: 100, height: 100)
                } else {
                    DefaultProfileImage(size: 100)
                }
                
                Text(viewModel.entrepreneur.fullName ?? "Entrepreneur Name")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(viewModel.entrepreneur.email ?? "email@example.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            if isEditable {
                Button(action: { showingEditProfile = true }) {
                    Image(systemName: "pencil")
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .offset(x: 10, y: -10)
            }
        }
    }
    
    private var entrepreneurStory: some View {
        VStack(alignment: .center) {
            Text("Entrepreneur's Story")
                .font(.custom("Zapfino", size: 24))
                .foregroundColor(.purple1)
            
            Text(viewModel.entrepreneur.bioDescr ?? "Share your entrepreneurial journey here! Tell us about your passion, vision, and what inspired you to start your business. Your story can inspire others...")
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .foregroundColor(.purple1)
    }
    
    private var companiesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.companies.isEmpty {
                Text("No companies to show")
                    .foregroundColor(.secondary)
                    .padding()
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
                                    AddCompanyView(viewModel: AddCompanyViewModel(), 
                                                 entrepreneur: viewModel.entrepreneur,
                                                 editingCompany: company)
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.purple1)
                                        .padding(8)
                                        .background(Color.white)
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
            if isEditable {
                addCompanyButton
                    .padding(.top)
            }
        }
        .alert("Delete Company", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let company = selectedCompanyToEdit {
                    Task {
                        try await viewModel.deleteCompany(company)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this company? This action cannot be undone.")
        }
    }
    
    private var addCompanyButton: some View {
        NavigationLink(destination: AddCompanyView(viewModel: AddCompanyViewModel(), entrepreneur: viewModel.entrepreneur)) {
            Text("Add Company")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.pink1)
                .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
