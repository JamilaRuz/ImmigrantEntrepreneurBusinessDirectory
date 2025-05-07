//
//  AboutView.swift
//  ImmigrantEntrepreneurCanada
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
                        Text("Immigrant Entrepreneur Canada")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .purple1)
                            .multilineTextAlignment(.center)
                        
                        Text("Business Directory")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .purple1)
                            .multilineTextAlignment(.center)
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("Version \(version) (\(build))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Organization description
                    Text("Immigrant Entrepreneur Canada (IEC), founded in March 2023, is the national center of excellence dedicated to empowering and accelerating the impact and success of immigrant entrepreneurs in Canada.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // App and organization details
                    VStack(alignment: .leading, spacing: 16) {
                        descriptionSection(
                            title: "Our Vision",
                            content: "To build a world that recognizes the immense value and contribution immigrant entrepreneurs bring to society. We envision a Canada where immigrant entrepreneurs thrive, drive innovation, create jobs, and enrich local communities, while fostering a nation that embraces diversity, cultivates inclusion, and sets the global standard for immigrant entrepreneurship.",
                            icon: "eye.fill"
                        )
                        
                        descriptionSection(
                            title: "Our Mission",
                            content: "To engage, connect, and empower Canadian immigrants through comprehensive education, dedicated advocacy, and a commitment to building opportunities for acquiring, starting, and scaling ventures. We are the driving force behind a movement that propels immigrant entrepreneurs to the forefront of Canada's entrepreneurial ecosystems and beyond.",
                            icon: "bolt.fill"
                        )
                        
                        descriptionSection(
                            title: "About This App",
                            content: "The Immigrant Entrepreneur Business Directory app is designed to connect immigrant entrepreneurs with customers and each other. Our app creates a centralized hub where users can discover, support, and engage with diverse, immigrant-owned businesses across Canada.",
                            icon: "app.fill"
                        )
                        
                        descriptionSection(
                            title: "Why Use This App",
                            content: "• Discover and connect with immigrant-owned businesses\n• Support the economic growth of immigrant entrepreneurs\n• Join a community that champions diversity and inclusion\n• Showcase your business to potential customers and partners\n• Contribute to building a strong, inclusive entrepreneurial ecosystem",
                            icon: "sparkles"
                        )
                        
                        descriptionSection(
                            title: "Contact Us",
                            content: "Have questions or suggestions? Email us at:\nadmin@immigrantentrepreneurcanada.ca",
                            icon: "envelope.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Copyright info
                    Text("© 2024 Immigrant Entrepreneur Canada. All rights reserved.")
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