//
//  NavigationBarModifier.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 10/4/24.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @Binding var isLoggedIn: Bool
    let activeFiltersCount: Int
    @State private var showToast = false
    @State private var toastMessage = "You have signed out"
    @State private var showFilterSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showAboutView = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var deleteError: String?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    LogoView(width: 35, height: 35, cornerRadius: 8)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Filter button
                        Button {
                            showFilterSheet = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .imageScale(.large)
                                    .foregroundColor(Color("pink1"))
                                
                                if activeFiltersCount > 0 {
                                    Text("\(activeFiltersCount)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color("pink1"))
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                        
                        // Settings button
                        Menu {
                            // About section
                            Section("About") {
                                Button {
                                    showAboutView = true
                                } label: {
                                    Label("About", systemImage: "info.circle")
                                }
                                
                                Button {
                                    showPrivacyPolicy = true
                                } label: {
                                    Label("Privacy Policy", systemImage: "lock.shield")
                                }
                                
                                Button {
                                    showTermsOfService = true
                                } label: {
                                    Label("Terms of Use", systemImage: "doc.text")
                                }
                            }
                            
                            // Account section
                            if isLoggedIn {
                                Section("Account") {
                                    Button {
                                        Task {
                                            do {
                                                try viewModel.signOut()
                                                isLoggedIn = false
                                                toastMessage = "You have signed out"
                                                showToast = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    showToast = false
                                                }
                                            } catch {
                                                print("Error signing out: \(error)")
                                            }
                                        }
                                    } label: {
                                        Label("Sign Out", systemImage: "arrow.left.circle.fill")
                                    }
                                    
                                    Button(role: .destructive) {
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete Account", systemImage: "xmark.circle.fill")
                                    }
                                }
                            } else {
                                Button("Sign In") {
                                    showSignInView = true
                                }
                            }
                        } label: {
                            Image(systemName: "gearshape")
                                .imageScale(.large)
                                .foregroundColor(isLoggedIn ? Color("pink1") : Color.gray)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                VStack {
                    if showToast {
                        Text(toastMessage)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                    .animation(.easeInOut, value: showToast)
                    .padding(.top, 50)
            )
            .sheet(isPresented: $showFilterSheet) {
                FilterView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showAboutView) {
                AboutView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                LegalDocumentsView(documentType: .privacyPolicy)
            }
            .sheet(isPresented: $showTermsOfService) {
                LegalDocumentsView(documentType: .termsOfService)
            }
            .sheet(isPresented: $viewModel.showDeleteReauthDialog) {
                AuthenticationView(showSignInView: .constant(true), userIsLoggedIn: .constant(false)) {
                    Task {
                        do {
                            try await viewModel.deleteAccount()

                            let alertController = UIAlertController(
                                title: "Delete Account",
                                message: "Your account has been deleted.",
                                preferredStyle: .alert
                            )
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                viewModel.showDeleteReauthDialog = false
                                do {
                                    try viewModel.signOut()
                                    isLoggedIn = false
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }))
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                            let rootViewController = windowScene.windows.first?.rootViewController {
                                var currentVC = rootViewController
                                while let presentedVC = currentVC.presentedViewController {
                                    currentVC = presentedVC
                                }
                                currentVC.present(alertController, animated: true)
                            }
                        } catch {
                            deleteError = error.localizedDescription
                        }
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    let alertController = UIAlertController(
                        title: "Delete Account",
                        message: "Please sign in again before deleting your account.",
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        viewModel.showDeleteReauthDialog = true
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        var currentVC = rootViewController
                        while let presentedVC = currentVC.presentedViewController {
                            currentVC = presentedVC
                        }
                        currentVC.present(alertController, animated: true)
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This will permanently delete all your data including your profile, companies, and all associated images. This action cannot be undone.")
            }
            .alert("Error", isPresented: .init(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )) {
                Button("OK", role: .cancel) {
                    deleteError = nil
                }
            } message: {
                if let error = deleteError {
                    Text(error)
                }
            }
    }
}

extension View {
    func customNavigationBar(showSignInView: Binding<Bool>, isLoggedIn: Binding<Bool>, activeFiltersCount: Int = 0) -> some View {
        self.modifier(NavigationBarModifier(
            showSignInView: showSignInView,
            isLoggedIn: isLoggedIn,
            activeFiltersCount: activeFiltersCount
        ))
    }
}
