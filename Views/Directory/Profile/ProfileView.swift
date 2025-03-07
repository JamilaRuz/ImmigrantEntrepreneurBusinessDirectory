private var entrepreneurStory: some View {
    VStack(alignment: .center, spacing: 12) {
        Text("Entrepreneur's Story")
            .font(.custom("Zapfino", size: 20))
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
                    .foregroundColor(.purple1.opacity(0.8))
                
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
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.purple1.opacity(0.05))
            .cornerRadius(12)
        }
    }
    .padding(.vertical, 10)
}

private var addCompanyButton: some View {
    NavigationLink(
        destination: AddCompanyView(
            viewModel: AddCompanyViewModel(),
            entrepreneur: viewModel.entrepreneur
        ) {
            // Refresh data when company is created
            Task {
                do {
                    try await viewModel.loadData(for: entrepreneur)
                } catch {
                    print("Failed to refresh data after adding company: \(error)")
                }
            }
        }
    ) {
        Text("Add Company")
            .font(.headline)
            .foregroundColor(.pink1)
            .frame(width: 150, height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(.vertical, 10)
}

private var companiesList: some View {
    VStack(alignment: .leading, spacing: 16) {
        if viewModel.companies.isEmpty {
            emptyCompaniesView
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

private var emptyCompaniesView: some View {
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
} 