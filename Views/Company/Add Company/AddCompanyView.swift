// ... existing code ...
              Circle()
                .fill(index == currentPage ? Color.orange1 : Color.gray.opacity(0.3))
                .frame(width: 12, height: 12)
              Text(stepTitle(for: index))
                .font(.caption2)
                .foregroundColor(index == currentPage ? Color.orange1 : .gray)
            }
            if index < 2 {
              Rectangle()
                .fill(index < currentPage ? Color.orange1 : Color.gray.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: 50)
            }
// ... existing code ...
          .frame(maxWidth: .infinity)
          .padding()
          .background(isFormValid ? Color.orange1 : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(12)
          .shadow(radius: 2)
// ... existing code ...
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange1.opacity(0.1))
            .foregroundColor(.orange1)
            .cornerRadius(8)
// ... existing code ...
                        Image(systemName: selectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedTypes.contains(type) ? .orange1 : .gray)
// ... existing code ...
          HStack {
            Text(currentPage < 2 ? "Next" : (editingCompany != nil ? "Save Changes" : "Save Company"))
              .fontWeight(.semibold)
            Image(systemName: currentPage < 2 ? "arrow.right" : "checkmark")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(isFormValid ? Color.orange1 : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(12)
          .shadow(radius: 2)

struct ImagePickerButton: View {
    let title: String
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: { isPresented = true }) {
            HStack {
                Image(systemName: "photo")
                Text(image == nil ? "Add \(title)" : "Change \(title)")
                if image != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange1.opacity(0.1))
            .foregroundColor(.orange1)
            .cornerRadius(8)
        }
    }
}

struct OwnershipTypeGrid: View {
    @Binding var selectedTypes: Set<Company.OwnershipType>
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(Company.OwnershipType.allCases, id: \.self) { type in
                Button(action: {
                    if selectedTypes.contains(type) {
                        selectedTypes.remove(type)
                    } else {
                        selectedTypes.insert(type)
                    }
                }) {
                    HStack {
                        Image(systemName: selectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedTypes.contains(type) ? .orange1 : .gray)
                        Text(type.rawValue)
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}

private func saveOrUpdateCompany() async throws {
    if let editingCompany = editingCompany {
        try await viewModel.updateCompany(
            company: editingCompany,
            companyName: companyName,
            logoImage: logoImage,
            headerImage: headerImage,
            portfolioImages: portfolioImages,
            aboutUs: aboutUs,
            dateFounded: dateFounded,
            workHours: workHoursValue,
            services: services,
            businessModel: businessModel,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            website: website,
            socialMediaInsta: socialMediaInsta,
            socialMediaFacebook: socialMediaFacebook,
            selectedCategoryIds: selectedCategoryIds,
            selectedOwnershipTypes: selectedOwnershipTypes
        )
        onCompanyCreated?() // Call the callback after successful update
    } else {
        try await viewModel.saveCompany(
            entrepreneur: entrepreneur,
            companyName: companyName,
            logoImage: logoImage,
            headerImage: headerImage,
            portfolioImages: portfolioImages,
            aboutUs: aboutUs,
            dateFounded: dateFounded,
            workHours: workHoursValue,
            services: services,
            businessModel: businessModel,
            address: address,
            city: city,
            phoneNum: phoneNum,
            email: email,
            website: website,
            socialMediaInsta: socialMediaInsta,
            socialMediaFacebook: socialMediaFacebook,
            selectedCategoryIds: selectedCategoryIds,
            selectedOwnershipTypes: selectedOwnershipTypes
        )
        onCompanyCreated?() // Call the callback after successful creation
    }
    dismiss()
}