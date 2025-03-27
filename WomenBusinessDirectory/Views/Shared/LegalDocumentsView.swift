//
//  LegalDocumentsView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 3/26/24.
//

import SwiftUI

struct LegalDocumentsView: View {
    enum DocumentType {
        case privacyPolicy
        case termsOfService
        
        var title: String {
            switch self {
            case .privacyPolicy:
                return "Privacy Policy"
            case .termsOfService:
                return "Terms of Service"
            }
        }
    }
    
    let documentType: DocumentType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // In Progress Notice
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Content is being updated")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Header
                    Text("Last Updated: March 26, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    // Index section for Privacy Policy
                    if documentType == .privacyPolicy {
                        Text("Index")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            indexItem("What Information Do We Collect?")
                            indexItem("How and Why We Use Your Information")
                            indexItem("How and Why We Share Your Information")
                            indexItem("Your Controls and Choices")
                            indexItem("Children")
                            indexItem("Data Security and Retention")
                            indexItem("Changes to the Privacy Policy")
                            indexItem("Contact Us")
                        }
                        .padding(.bottom, 24)
                    }
                    
                    // Main content
                    switch documentType {
                    case .privacyPolicy:
                        privacyPolicyContent
                    case .termsOfService:
                        termsOfServiceContent
                    }
                }
                .padding()
            }
            .navigationTitle(documentType.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
        }
    }
    
    private func indexItem(_ text: String) -> some View {
        HStack(spacing: 8) {
            Text("-")
                .foregroundColor(.gray)
            Text(text)
                .foregroundColor(.primary)
        }
    }
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                sectionTitle("What Information Do We Collect?")
                Text("In the course of providing and improving our products and services, we collect your personal information for the purposes described in this Privacy Policy. The following are the types of personal information that we collect:")
                    .foregroundColor(.secondary)
                
                Text("Information that you provide")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("When you create an account, place an order at checkout, contact us directly, or otherwise use the Service, you may provide some or all of the following information:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Account and Profile: In order to create and manage your account, we may collect your mobile phone number or email address as the login credentials for your account.")
                }
            }
            
            // Add other sections similarly...
        }
    }
    
    private var termsOfServiceContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("These Terms of Service (\"Terms\") govern your use of the Women Business Directory mobile application.")
                .foregroundColor(.secondary)
            
            Group {
                sectionTitle("Overview")
                Text("By using our Services, you agree to be bound by these Terms. If you do not agree to these Terms, you are not permitted to use the Services or place orders for any Products.")
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .padding(.vertical, 8)
            }
            
            // Add other sections similarly...
        }
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top, 8)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .foregroundColor(.gray)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

struct LegalDocumentsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDocument: LegalDocumentsView.DocumentType?
    
    var body: some View {
        NavigationView {
            List {
                // In Progress Notice
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Legal documents are being updated")
                            .font(.footnote)
                        Spacer()
                    }
                    .listRowBackground(Color.orange.opacity(0.1))
                }
                
                Section {
                    Button {
                        selectedDocument = .privacyPolicy
                    } label: {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.blue)
                            Text("Privacy Policy")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    Button {
                        selectedDocument = .termsOfService
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Terms of Service")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Legal Documents")
                } footer: {
                    Text("These documents outline how your data is used and the terms for using our app.")
                }
            }
            .navigationTitle("Legal")
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
        .sheet(item: $selectedDocument) { documentType in
            LegalDocumentsView(documentType: documentType)
        }
    }
}

extension LegalDocumentsView.DocumentType: Identifiable {
    var id: String {
        switch self {
        case .privacyPolicy:
            return "privacy_policy"
        case .termsOfService:
            return "terms_of_service"
        }
    }
}

#Preview("Legal Documents List") {
    LegalDocumentsListView()
}

#Preview("Privacy Policy") {
    LegalDocumentsView(documentType: .privacyPolicy)
}

#Preview("Terms of Service") {
    LegalDocumentsView(documentType: .termsOfService)
} 
