//
//  AboutView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 3/26/24.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    // App logo
                    LogoView(width: 100, height: 100, cornerRadius: 22)
                        .padding(.top, 20)
                    
                    // App name and version
                    VStack(spacing: 4) {
                        Text("Immigrant Entrepreneur Business Directory")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .purple1)
                            .multilineTextAlignment(.center)
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("Version \(version) (\(build))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // App description
                    VStack(alignment: .leading, spacing: 16) {
                        descriptionSection(
                            title: "Our Mission",
                            content: "Immigrant Entrepreneur Business Directory connects immigrant entrepreneurs with customers, promoting diverse, immigrant-owned businesses to global audiences.",
                            icon: "bolt.fill"
                        )
                        
                        descriptionSection(
                            title: "Why Use This App",
                            content: "• Discover immigrant-owned businesses\n• Support immigrant entrepreneurs globally\n• Connect with like-minded business owners\n• Share your own business with potential customers",
                            icon: "sparkles"
                        )
                        
                        descriptionSection(
                            title: "Contact Us",
                            content: "Have questions or suggestions? Email us at:\nsupport@immigrantbusinessdirectory.com",
                            icon: "envelope.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Copyright info
                    Text("© 2024 Immigrant Entrepreneur Business Directory. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(colorScheme == .dark ? .white : Color.pink1)
                    }
                }
            }
        }
    }
    
    private func descriptionSection(title: String, content: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(colorScheme == .dark ? .white : .purple1)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .purple1)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.purple1.opacity(0.05))
        )
    }
}

#Preview {
    AboutView()
} 