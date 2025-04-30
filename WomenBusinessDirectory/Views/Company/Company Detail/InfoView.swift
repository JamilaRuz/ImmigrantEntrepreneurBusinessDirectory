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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // About Us section
            VStack(alignment: .leading, spacing: 8) {
                Text("About Us")
                    .font(.headline)
                    .padding(.top, 10) // Add consistent top padding
                
                if company.aboutUs.isEmpty {
                    Text("No company description available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    CompanyExpandableTextView(text: company.aboutUs, title: "About Us", color: colorScheme == .dark ? .gray.opacity(0.9) : .gray)
                }
            }
            
            Divider() // Visual separator
            
            // Company Address Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Address")
                    .font(.headline)
                
                if company.address.isEmpty && company.city.isEmpty {
                    Text("No address available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(company.address), \(company.city)")
                                .font(.body)
                                .foregroundColor(colorScheme == .dark ? .gray.opacity(0.9) : .gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            openInGoogleMaps()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                }
            }
            
            Divider() // Visual separator
            
            // Social Media Links Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Connect With Us")
                    .font(.headline)
                
                if company.socialMediaPlatforms.isEmpty && company.website.isEmpty {
                    Text("No social media links available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Website button (if available)
                            if !company.website.isEmpty {
                                Button(action: {
                                    if let url = URL(string: company.website.hasPrefix("http") ? company.website : "https://" + company.website) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "globe")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16))
                                        
                                        Text("Website")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.05))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Facebook
                            if company.socialMediaPlatforms.contains(.facebook) {
                                SocialMediaLinkButton(
                                    platform: .facebook,
                                    color: Color.blue1,
                                    company: company
                                )
                            }
                            
                            // Instagram
                            if company.socialMediaPlatforms.contains(.instagram) {
                                SocialMediaLinkButton(
                                    platform: .instagram,
                                    color: Color.blue1,
                                    company: company
                                )
                            }
                            
                            // Twitter
                            if company.socialMediaPlatforms.contains(.twitter) {
                                SocialMediaLinkButton(
                                    platform: .twitter,
                                    color: Color.blue1,
                                    company: company
                                )
                            }
                            
                            // LinkedIn
                            if company.socialMediaPlatforms.contains(.linkedin) {
                                SocialMediaLinkButton(
                                    platform: .linkedin,
                                    color: Color.blue1,
                                    company: company
                                )
                            }
                            
                            // YouTube
                            if company.socialMediaPlatforms.contains(.youtube) {
                                SocialMediaLinkButton(
                                    platform: .youtube,
                                    color: Color.blue1,
                                    company: company
                                )
                            }
                            
                            // Other
                            if company.socialMediaPlatforms.contains(.other) {
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
            }
            
            Divider() // Visual separator
            
            // Founder Section - Simplified to only show image and name
            VStack(alignment: .leading, spacing: 8) {
                Text("Founder")
                    .font(.headline)
                
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading entrepreneur info...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                } else if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                } else if viewModel.entrepreneur.fullName?.isEmpty ?? true {
                    Text("No founder information available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    HStack {
                        CachedAsyncImage(url: URL(string: viewModel.entrepreneur.profileUrl ?? "")) { phase in
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
                        
                        Text(viewModel.entrepreneur.fullName ?? "Unknown")
                            .font(.body)
                    }
                    .padding(.vertical, 2) // Reduce padding from 4 to 2
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 0)
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
    
    private func openInGoogleMaps() {
        let address = "\(company.address), \(company.city)"
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try to open in Google Maps app first
        let googleMapsAppURL = URL(string: "comgooglemaps://?q=\(encodedAddress)&directionsmode=driving")
        
        // If Google Maps app is installed, open it
        if let googleMapsAppURL = googleMapsAppURL, UIApplication.shared.canOpenURL(googleMapsAppURL) {
            UIApplication.shared.open(googleMapsAppURL)
        } else {
            // Fallback to Google Maps web
            let googleMapsWebURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedAddress)")
            
            // Open in web browser
            if let googleMapsWebURL = googleMapsWebURL {
                UIApplication.shared.open(googleMapsWebURL)
            }
        }
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            openLink(for: platform)
        }) {
            HStack(spacing: 6) {
                Image(systemName: platform.icon)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                Text(displayName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    // A computed property to show a user-friendly display name
    private var displayName: String {
        if let socialMedias = company.socialMedias,
           let link = socialMedias[platform],
           !link.isEmpty {
            // Extract username from the full URL for better display
            switch platform {
            case .instagram:
                if let username = extractUsername(from: link, prefix: "instagram.com/") {
                    return "@\(username)"
                }
            case .twitter:
                if let username = extractUsername(from: link, prefix: "twitter.com/") {
                    return "@\(username)"
                }
            case .facebook:
                if let pageName = extractUsername(from: link, prefix: "facebook.com/") {
                    return pageName
                }
            case .linkedin:
                return "LinkedIn"
            case .youtube:
                return "YouTube"
            case .other:
                // For other, try to extract the domain
                if let domain = extractDomain(from: link) {
                    return domain
                }
            }
        }
        
        // Default fallback
        return platform.rawValue
    }
    
    // Helper to extract username from social media URL
    private func extractUsername(from url: String, prefix: String) -> String? {
        let lowercasedUrl = url.lowercased()
        
        // Handle URLs with or without https://
        let prefixVariants = ["https://\(prefix)", "http://\(prefix)", "\(prefix)"]
        
        for variant in prefixVariants {
            if lowercasedUrl.hasPrefix(variant) {
                let startIndex = url.index(url.startIndex, offsetBy: variant.count)
                var username = String(url[startIndex...])
                
                // Remove any trailing parameters or path components
                if let endIndex = username.firstIndex(of: "?") {
                    username = String(username[..<endIndex])
                }
                if let endIndex = username.firstIndex(of: "#") {
                    username = String(username[..<endIndex])
                }
                if let endIndex = username.firstIndex(of: "/") {
                    username = String(username[..<endIndex])
                }
                
                return username
            }
        }
        
        return nil
    }
    
    // Helper to extract domain from URL
    private func extractDomain(from url: String) -> String? {
        // Remove protocol
        var domainString = url
        if domainString.lowercased().hasPrefix("https://") {
            domainString = String(domainString.dropFirst(8))
        } else if domainString.lowercased().hasPrefix("http://") {
            domainString = String(domainString.dropFirst(7))
        }
        
        // Remove www. if present
        if domainString.lowercased().hasPrefix("www.") {
            domainString = String(domainString.dropFirst(4))
        }
        
        // Take only the domain part (before first slash)
        if let endIndex = domainString.firstIndex(of: "/") {
            domainString = String(domainString[..<endIndex])
        }
        
        return domainString
    }
    
    private func getSocialMediaHandle(for platform: Company.SocialMedia) -> String {
        // Check if we have a stored link for this platform
        if let socialMedias = company.socialMedias,
           let link = socialMedias[platform], 
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
        if let socialMedias = company.socialMedias,
           let link = socialMedias[platform], 
           !link.isEmpty {
            // The link should already be properly formatted with https://
            urlString = link
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

struct CompanyExpandableTextView: View {
    let text: String
    let title: String
    let color: Color
    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var lineLimit = 3
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.body)
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Detect if text is truncated
                    GeometryReader { geometry in
                        ZStack {
                            // Create two text views to compare their heights
                            Text(text)
                                .font(.body)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .hidden()
                                .background(
                                    GeometryReader { fullTextGeometry in
                                        Color.clear.onAppear {
                                            // Compare the height of truncated vs full text
                                            let truncated = fullTextGeometry.size.height > geometry.size.height
                                            DispatchQueue.main.async {
                                                isTruncated = truncated
                                            }
                                        }
                                    }
                                )
                        }
                    }
                )
                .fixedSize(horizontal: false, vertical: true)
            
            if isTruncated && !isExpanded {
                Button(action: {
                    isExpanded = true
                }) {
                    Text("more...")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top, 4)
            }
        }
        .sheet(isPresented: $isExpanded) {
            ZStack {
                // Background that matches the parent view's color scheme
                (colorScheme == .dark ? Color.black : Color(.systemBackground))
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(title)
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        Text(text)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .gray.opacity(0.9) : .gray)
                            .lineSpacing(8)
                        
                        Spacer()
                    }
                    .padding(24)
                }
                .overlay(
                    Button(action: {
                        isExpanded = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                            .padding()
                    }, alignment: .topTrailing
                )
            }
        }
    }
}
