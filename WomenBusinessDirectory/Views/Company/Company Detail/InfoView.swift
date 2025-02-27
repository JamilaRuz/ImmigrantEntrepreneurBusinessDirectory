//
//  InfoView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import SwiftUI

struct InfoView: View {
    let company: Company
    @StateObject private var viewModel = InfoViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("About Us")
                    .font(.headline)
                    .padding(.top, 15)
                
                ScrollView {
                    Text(company.aboutUs)
                        .font(.body)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 100)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Social Media Links Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Connect With Us")
                    .font(.headline)
                
                if company.socialMedias.isEmpty {
                    Text("No social media links available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    VStack(spacing: 8) {
                        // Facebook
                        if company.socialMedias.contains(.facebook) {
                            SocialMediaLinkButton(
                                platform: .facebook,
                                color: Color.blue1,
                                company: company
                            )
                            if shouldShowDivider(platform: .facebook, in: company.socialMedias) {
                                Divider()
                            }
                        }
                        
                        // Instagram
                        if company.socialMedias.contains(.instagram) {
                            SocialMediaLinkButton(
                                platform: .instagram,
                                color: Color.blue1,
                                company: company
                            )
                            if shouldShowDivider(platform: .instagram, in: company.socialMedias) {
                                Divider()
                            }
                        }
                        
                        // Twitter
                        if company.socialMedias.contains(.twitter) {
                            SocialMediaLinkButton(
                                platform: .twitter,
                                color: Color.blue1,
                                company: company
                            )
                            if shouldShowDivider(platform: .twitter, in: company.socialMedias) {
                                Divider()
                            }
                        }
                        
                        // LinkedIn
                        if company.socialMedias.contains(.linkedin) {
                            SocialMediaLinkButton(
                                platform: .linkedin,
                                color: Color.blue1,
                                company: company
                            )
                            if shouldShowDivider(platform: .linkedin, in: company.socialMedias) {
                                Divider()
                            }
                        }
                        
                        // YouTube
                        if company.socialMedias.contains(.youtube) {
                            SocialMediaLinkButton(
                                platform: .youtube,
                                color: Color.blue1,
                                company: company
                            )
                            if shouldShowDivider(platform: .youtube, in: company.socialMedias) {
                                Divider()
                            }
                        }
                        
                        // Other
                        if company.socialMedias.contains(.other) {
                            SocialMediaLinkButton(
                                platform: .other,
                                color: Color.blue1,
                                company: company
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading entrepreneur info...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    HStack {
                        AsyncImage(url: URL(string: viewModel.entrepreneur.profileUrl ?? "")) { phase in
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
                            @unknown default:
                                DefaultProfileImage(size: 50)
                            }
                        }
                        .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Founder")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(viewModel.entrepreneur.fullName ?? "Unknown")
                                .font(.body)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadEntrepreneur(entrepId: company.entrepId)
            }
        }
    }
    
    // Helper function to determine if a divider should be shown after a platform
    private func shouldShowDivider(platform: Company.SocialMedia, in platforms: [Company.SocialMedia]) -> Bool {
        // Get the index of the current platform
        guard let index = platforms.firstIndex(of: platform) else { return false }
        
        // If this is not the last platform, show a divider
        return index < platforms.count - 1
    }
}

class InfoViewModel: ObservableObject {
    @Published var entrepreneur: Entrepreneur = Entrepreneur(entrepId: "", fullName: "", profileUrl: nil, email: "", bioDescr: "", companyIds: [])
    @Published var isLoading = false
    @Published var error: String?
    
    @MainActor
    func loadEntrepreneur(entrepId: String) async {
        isLoading = true
        error = nil
        
        do {
            self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: entrepId)
        } catch {
            print("Failed to load entrepreneur: \(error)")
            self.error = "Failed to load entrepreneur information. Please try again later."
        }
        
        isLoading = false
    }
}

#Preview {
    InfoView(company: createStubCompanies()[0])
}

struct SocialMediaLinkButton: View {
    let platform: Company.SocialMedia
    let color: Color
    let company: Company
    
    var body: some View {
        Button(action: {
            openLink(for: platform)
        }) {
            HStack {
                // Platform icon in a circular background
                ZStack {
                    Circle()
                        .fill(Color.blue1.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: platform.icon)
                        .foregroundColor(Color.blue1)
                        .font(.system(size: 16))
                }
                
                // Platform name
                Text(platform.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Social media handle/URL
                Text(getSocialMediaHandle(for: platform))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func getSocialMediaHandle(for platform: Company.SocialMedia) -> String {
        // Check if we have a stored link for this platform
        if let socialMedia = company.socialMedia,
           let link = socialMedia[platform], 
           !link.isEmpty {
            // Return the link exactly as entered by the user
            return link
        }
        
        // Fallback to default placeholders if no link is available
        switch platform {
        case .facebook:
            return "Facebook Profile"
        case .instagram:
            return "Instagram Profile"
        case .twitter:
            return "Twitter Profile"
        case .linkedin:
            return "LinkedIn Profile"
        case .youtube:
            return "YouTube Channel"
        case .other:
            return company.website.isEmpty ? "Website" : company.website
        }
    }
    
    private func openLink(for platform: Company.SocialMedia) {
        var urlString: String?
        
        // Try to get the stored link first
        if let socialMedia = company.socialMedia,
           let link = socialMedia[platform], 
           !link.isEmpty {
            // If the link doesn't start with http:// or https://, add https://
            if !link.lowercased().hasPrefix("http://") && !link.lowercased().hasPrefix("https://") {
                urlString = "https://" + link
            } else {
                urlString = link
            }
        } else if platform == .other && !company.website.isEmpty {
            // For "Other" platform, use the website if available
            if !company.website.lowercased().hasPrefix("http://") && !company.website.lowercased().hasPrefix("https://") {
                urlString = "https://" + company.website
            } else {
                urlString = company.website
            }
        } else {
            // Fallback to default URLs based on platform
            switch platform {
            case .facebook:
                urlString = "https://facebook.com"
            case .instagram:
                urlString = "https://instagram.com"
            case .twitter:
                urlString = "https://twitter.com"
            case .linkedin:
                urlString = "https://linkedin.com"
            case .youtube:
                urlString = "https://youtube.com"
            case .other:
                urlString = nil
            }
        }
        
        // Open the URL if we have one
        if let urlString = urlString, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
