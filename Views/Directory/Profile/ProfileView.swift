private var entrepreneurStory: some View {
    VStack(alignment: .center) {
        Text("Entrepreneur's Story")
            .font(.custom("Zapfino", size: 20))
            .foregroundColor(.purple1)
        
        Text(viewModel.entrepreneur.bioDescr ?? "Share your entrepreneurial journey here! Tell us about your passion, vision, and what inspired you to start your business. Your story can inspire others...")
            .font(.subheadline)
            .italic()
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    .foregroundColor(.purple1)
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
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.pink1)
            .cornerRadius(10)
    }
} 