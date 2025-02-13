import SwiftUI

struct CompanyRowView: View {
    let company: Company
    let categories: [Category]
    
    init(company: Company, categories: [Category]) {
        self.company = company
        self.categories = categories
    }
    
    private func getCategoryNames(for company: Company) -> [String] {
        return company.categoryIds.compactMap { categoryId in
            categories.first(where: { $0.id == categoryId })?.name
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Content VStack
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    // Company Logo
                    AsyncImage(url: URL(string: company.logoImg ?? "")) { phase in
                        switch phase {
                        case .empty, .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(company.name)
                            .font(.headline)
                        
                        // Categories horizontal scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(getCategoryNames(for: company), id: \.self) { categoryName in
                                    Text(categoryName)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.yellow.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text(company.workHours)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Text(company.aboutUs)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Services scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(company.services, id: \.self) { service in
                            Text(service)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Arrow VStack
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray.opacity(0.5))
                    .frame(width: 20)
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    CompanyRowView(
        company: Company(
            companyId: "1",
            entrepId: "123",
            categoryIds: ["1", "2"],
            name: "Test Company",
            logoImg: nil,
            aboutUs: "This is a test company description",
            dateFounded: "11.11.2011",
            portfolioImages: [],
            address: "123 Main St",
            city: "Sample City",
            phoneNum: "555-1234",
            email: "test@example.com",
            workHours: "Mon-Fri 9-5",
            services: ["Service 1", "Service 2"],
            socialMediaFacebook: "facebook.com/testcompany",
            socialMediaInsta: "instagram.com/testcompany",
            businessModel: .hybrid,
            website: "www.testcompany.com",
            ownershipTypes: [.asianOwned],
            isBookmarked: false
        ),
        categories: [
            Category(id: "1", name: "Category 1", systemIconName: "star"),
            Category(id: "2", name: "Category 2", systemIconName: "heart.fill")
        ]
    )
}
