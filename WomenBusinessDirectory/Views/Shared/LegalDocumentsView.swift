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
        
        var filename: String {
            switch self {
            case .privacyPolicy:
                return "privacy_policy"
            case .termsOfService:
                return "terms_of_service"
            }
        }
    }
    
    let documentType: DocumentType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var documentText: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !documentText.isEmpty {
                        Text(.init(documentText))
                            .padding()
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(documentType.title)
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
            .onAppear {
                loadDocument()
            }
        }
    }
    
    private func loadDocument() {
        print("Attempting to load \(documentType.filename).md")
        let fileManager = FileManager.default
        
        // Try most direct method first - explicitly loading from the project's Legal directory
        let fileName = documentType.filename + ".md"
        let projectPath = "/Users/jamila/Work/iOS_Projects/WomenBusinessDirectory/WomenBusinessDirectory/Legal/\(fileName)"
        
        if fileManager.fileExists(atPath: projectPath) {
            print("✅ Found document at direct project path: \(projectPath)")
            loadFromPath(projectPath)
            return
        } else {
            print("❌ Document not found at direct project path: \(projectPath)")
        }
        
        // For development, try to load using file-relative path
        #if DEBUG
        // Get the project directory path
        let projectDir = URL(fileURLWithPath: #file)
            .deletingLastPathComponent() // Views/Shared
            .deletingLastPathComponent() // Views
            .deletingLastPathComponent() // WomenBusinessDirectory
        
        // Try to load from project's Legal directory
        let legalPath = projectDir.appendingPathComponent("Legal").appendingPathComponent("\(documentType.filename).md")
        
        print("⏳ Checking file-relative path: \(legalPath.path)")
        if fileManager.fileExists(atPath: legalPath.path) {
            print("✅ Found document at file-relative path: \(legalPath.path)")
            loadFromPath(legalPath.path)
            return
        } else {
            print("❌ Document not found at file-relative path: \(legalPath.path)")
            
            // List files in the Legal directory to debug
            if let legalDirContents = try? fileManager.contentsOfDirectory(atPath: projectDir.appendingPathComponent("Legal").path) {
                print("📂 Contents of Legal directory: \(legalDirContents)")
            } else {
                print("📂 Could not list contents of Legal directory")
            }
        }
        #endif
        
        // List the bundle contents to help debugging
        print("📦 Bundle path: \(Bundle.main.bundlePath)")
        if let resourcePath = Bundle.main.resourcePath {
            print("📦 Resource path: \(resourcePath)")
            
            // Check if Legal directory exists in bundle
            let bundleLegalDir = resourcePath + "/Legal"
            if fileManager.fileExists(atPath: bundleLegalDir) {
                if let legalContents = try? fileManager.contentsOfDirectory(atPath: bundleLegalDir) {
                    print("📂 Legal directory contents in bundle: \(legalContents)")
                }
            } else {
                print("📂 Legal directory does not exist in bundle")
            }
        }
        
        // Try to load from bundle resources
        if let path = Bundle.main.path(forResource: documentType.filename, ofType: "md", inDirectory: "Legal") {
            print("✅ Found document in bundle Legal directory: \(path)")
            loadFromPath(path)
            return
        } else {
            print("❌ Document not found in bundle Legal directory")
        }
        
        // If still not found, create and display an embedded fallback version
        print("⚠️ No document found in any location, using fallback content")
        
        if documentType == .privacyPolicy {
            documentText = """
            # Privacy Policy
            
            **Last Updated: March 26, 2024**
            
            This Privacy Policy describes how Women Business Directory ("we," "us," or "our") collects, uses, and shares your personal information when you use our mobile application.
            
            ## Information We Collect
            
            - **Personal Information**: Name, email address, business details.
            - **Usage Data**: How you interact with our app.
            - **Device Information**: Device type, operating system.
            
            ## How We Use Your Information
            
            - To provide and maintain our Service
            - To improve our app and customer experience
            - To communicate with you
            
            ## Contact Us
            
            If you have any questions about this Privacy Policy, please contact us.
            """
        } else {
            documentText = """
            # Terms of Service
            
            **Last Updated: March 26, 2024**
            
            These Terms of Service ("Terms") govern your use of the Women Business Directory mobile application.
            
            ## User Accounts
            
            You are responsible for maintaining the confidentiality of your account.
            
            ## User Content
            
            You retain ownership of all content you submit to the App.
            
            ## Acceptable Use
            
            You agree not to use the App to violate any laws or harass others.
            
            ## Contact Us
            
            If you have any questions about these Terms, please contact us.
            """
        }
    }
    
    private func loadFromPath(_ path: String) {
        do {
            documentText = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            documentText = "Error loading document: \(error.localizedDescription)"
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