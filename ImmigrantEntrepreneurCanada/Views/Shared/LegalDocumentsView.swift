//
//  LegalDocumentsView.swift
//  ImmigrantEntrepreneurCanada
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
                    // Header
                    Text("Last Updated: April 8, 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    // Index section for Privacy Policy or Terms of Service
                    if documentType == .privacyPolicy {
                        Text("Index")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            indexItem("1. Information We Collect")
                            indexItem("2. How We Use Your Information")
                            indexItem("3. Information Sharing and Disclosure")
                            indexItem("4. Data Security")
                            indexItem("5. Your Choices")
                            indexItem("6. Children's Privacy")
                            indexItem("7. Changes to This Policy")
                            indexItem("8. Contact Us")
                        }
                        .padding(.bottom, 24)
                    } else if documentType == .termsOfService {
                        Text("Index")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            indexItem("1. Acceptance of Terms")
                            indexItem("2. Description of the Service")
                            indexItem("3. User Responsibilities")
                            indexItem("4. Content Ownership and License")
                            indexItem("5. Availability and Modifications")
                            indexItem("6. Termination")
                            indexItem("7. Disclaimer")
                            indexItem("8. Limitation of Liability")
                            indexItem("9. Governing Law")
                            indexItem("10. Contact Us")
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
            Text("Effective Date: April 8, 2025")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
                
            Text("Thank you for using our Immigrant Entrepreneur Canada (\"App\"). Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our App.")
                .foregroundColor(.secondary)
                
            Group {
                sectionTitle("1. Information We Collect")
                
                Text("When you use the App, we may collect the following information:")
                    .foregroundColor(.secondary)
                
                Text("Personal Information:")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Full name")
                    bulletPoint("Email address (personal and company)")
                }
                
                Text("Company Information:")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Company name")
                    bulletPoint("Services provided")
                    bulletPoint("Physical address")
                    bulletPoint("Phone number")
                }
            }
            
            Group {
                sectionTitle("2. How We Use Your Information")
                
                Text("We use the collected information to:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Create and manage your business listing in the directory")
                    bulletPoint("Enable other users to discover, contact, and connect with your business")
                    bulletPoint("Facilitate communication and networking among entrepreneurs")
                    bulletPoint("Improve the overall functionality and user experience of the App")
                }
            }
            
            Group {
                sectionTitle("3. Information Sharing and Disclosure")
                
                Text("All the information you provide, including personal and company details, will be publicly available to any user who downloads or accesses the App. This includes:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Displaying your company profile and contact information in the directory")
                    bulletPoint("Allowing other users to view and potentially reach out to you directly")
                }
                
                Text("We do not sell your information to third parties. However, since your information is visible to other users, it may be accessible to third parties through the public directory.")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            
            Group {
                sectionTitle("4. Data Security")
                
                Text("We implement reasonable administrative, technical, and physical security measures to protect your personal information. However, no method of transmission over the internet or method of electronic storage is 100% secure.")
                    .foregroundColor(.secondary)
                    
                Text("Database Protection:")
                    .font(.headline)
                    .padding(.top, 12)
                    
                Text("Our databases are secured and stored in environments protected by firewalls and authentication systems.")
                    .foregroundColor(.secondary)
                    
                Text("Data Minimization & Limitation:")
                    .font(.headline)
                    .padding(.top, 12)
                    
                Text("We only collect the data necessary for your listing to function properly in the directory.")
                    .foregroundColor(.secondary)
                    
                Text("Regular Security Updates:")
                    .font(.headline)
                    .padding(.top, 12)
                    
                Text("We keep our backend services and frameworks up to date with the latest security patches and fixes.")
                    .foregroundColor(.secondary)
                    
                Text("Monitoring and Logging:")
                    .font(.headline)
                    .padding(.top, 12)
                    
                Text("Access and changes to sensitive user data may be logged and monitored to detect unauthorized behavior.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("5. Your Choices")
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("You may review and update your personal and company information at any time through your account settings.")
                    bulletPoint("If you wish to remove your information from the directory, you may contact us at admin@immigrantentrepreneurcanada.ca or use the app's deletion feature if available.")
                }
            }
            
            Group {
                sectionTitle("6. Children's Privacy")
                
                Text("This App is not intended for children under the age of 13. We do not knowingly collect personal information from children.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("7. Changes to This Policy")
                
                Text("We may update this Privacy Policy from time to time. Any changes will be posted within the App, and the updated version will be effective as of the \"Effective Date\" above.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("8. Contact Us")
                
                Text("If you have any questions or concerns about this Privacy Policy, please contact us at:")
                    .foregroundColor(.secondary)
                
                Text("Email: admin@immigrantentrepreneurcanada.ca")
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
    
    private var termsOfServiceContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Effective Date: April 12, 2024")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
                
            Text("Please read these Terms of Use (\"Terms\") carefully before using the Immigrant Entrepreneur Canada App (\"App\", \"we\", \"our\", or \"us\"). By downloading, accessing, or using the App, you agree to be bound by these Terms. If you do not agree, do not use the App.")
                .foregroundColor(.secondary)
            
            Group {
                sectionTitle("1. Acceptance of Terms")
                
                Text("By creating an account or using this App, you acknowledge that you have read, understood, and agreed to be bound by these Terms and our Privacy Policy.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("2. Description of the Service")
                
                Text("The Immigrant Entrepreneur Canada App is a platform for entrepreneurs and business owners to publish and browse business information. The App allows users to:")
                    .foregroundColor(.secondary)
                    
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Create and manage personal and company profiles")
                    bulletPoint("Share business contact details (e.g., email, phone number, address)")
                    bulletPoint("Browse, search, and connect with other businesses")
                }
                
                Text("You understand and agree that all information you provide may be visible to other users of the App.")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            
            Group {
                sectionTitle("3. User Responsibilities")
                
                Text("You agree to:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Provide accurate, current, and complete information when creating your profile")
                    bulletPoint("Only publish information for a business that you own, represent, or have permission to list")
                    bulletPoint("Keep your login credentials secure and not share your account with others")
                    bulletPoint("Use the App in a lawful manner and not for any illegal or unauthorized purposes")
                }
                
                Text("You must not:")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("Post false, misleading, or deceptive information")
                    bulletPoint("Attempt to harvest or misuse other users' data")
                    bulletPoint("Interfere with or disrupt the App's operation or security")
                }
            }
            
            Group {
                sectionTitle("4. Content Ownership and License")
                
                Text("You retain ownership of the content and information you submit to the App. However, by submitting information, you grant us a non-exclusive, worldwide, royalty-free license to use, host, display, and share that content as necessary to operate and promote the App.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("5. Availability and Modifications")
                
                Text("We may modify or discontinue, temporarily or permanently, the App or any part of it at any time with or without notice. We reserve the right to update or revise these Terms at our discretion. Continued use of the App after changes constitutes acceptance of the new Terms.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("6. Termination")
                
                Text("We reserve the right to suspend or terminate your account if you violate these Terms or engage in any activity that harms the App, its users, or its reputation.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("7. Disclaimer")
                
                Text("The App is provided \"as is\" and \"as available\" without warranties of any kind. We do not guarantee that the App will be error-free, secure, or continuously available.")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                Text("We are not responsible for the accuracy of information published by users or for interactions between users.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("8. Limitation of Liability")
                
                Text("To the maximum extent permitted by law, we will not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the App, including but not limited to data loss, unauthorized access, or business interruptions.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("9. Governing Law")
                
                Text("These Terms are governed by and construed in accordance with the laws of Ontario, Canada, without regard to its conflict of law principles.")
                    .foregroundColor(.secondary)
            }
            
            Group {
                sectionTitle("10. Contact Us")
                
                Text("If you have any questions or concerns about these Terms, please contact us at:")
                    .foregroundColor(.secondary)
                
                Text("Email: admin@immigrantentrepreneurcanada.ca")
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
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
