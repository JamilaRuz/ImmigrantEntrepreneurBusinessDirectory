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
            // If viewing another entrepreneur's profile, use their data directly
            await MainActor.run {
                self.entrepreneur = entrepreneur
            }
        } else {
            // If no entrepreneur provided (viewing own profile), load current user's data
            try await loadCurrentEntrepreneur()
        }
        
        async let companiesTask = loadCompaniesOfEntrepreneur()
        async let categoriesTask = loadAllCategories()
        
        let (newCompanies, newCategories) = try await (companiesTask, categoriesTask)
        
        await MainActor.run {
            self.companies = newCompanies
            self.allCategories = newCategories
        }
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
                    
                    if isEditable {
                        addCompanyButton
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .task {
            do {
                try await viewModel.loadData(for: entrepreneur)
            } catch {
                print("Failed to load data: \(error)")
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(entrepreneur: viewModel.entrepreneur) {
                // Refresh data when edit view saves changes
                Task {
                    do {
                        try await viewModel.loadData(for: entrepreneur)
                    } catch {
                        print("Failed to refresh data after edit: \(error)")
                    }
                }
            }
        }
    }
    
    private var profileCard: some View {
        HStack(spacing: 15) {
            // Profile image with edit button overlay
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: URL(string: viewModel.entrepreneur.profileUrl ?? "")) { phase in
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
                
                if isEditable {
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .padding(6)
                            .foregroundColor(.white)
                            .background(Color.purple1)
                            .clipShape(Circle())
                    }
                    .offset(x: 5, y: -5)
                }
            }
            
            // Name and email
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.entrepreneur.fullName ?? "Entrepreneur Name")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(viewModel.entrepreneur.email ?? "email@example.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
    
    private var entrepreneurStory: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Tell us about yourself")
                .font(.title2)
                .italic()
                .foregroundColor(.purple1)
            
            if let bio = viewModel.entrepreneur.bioDescr, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.purple1)
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
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.purple1)
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
                    
                    Text("No companies to show")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add your business to showcase your products and services to potential customers.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.pink1.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
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
                                        editingCompany: company)
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.purple1)
                                        .padding(8)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                .onDisappear {
                                    Task {
                                        do {
                                            try await viewModel.loadData(for: entrepreneur)
                                        } catch {
                                            print("Failed to refresh data after edit: \(error)")
                                        }
                                    }
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
                            // Refresh the data after deletion
                            try await viewModel.loadData(for: entrepreneur)
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
            Text("Add Company")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.pink1)
                .frame(width: 150, height: 40)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.pink1.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onDisappear {
            Task { @MainActor in
                do {
                    try await viewModel.loadData(for: entrepreneur)
                } catch {
                    print("Failed to refresh data after adding company: \(error)")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
