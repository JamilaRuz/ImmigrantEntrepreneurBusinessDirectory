//
//  NavigationBarModifier.swift
//  WomenBusinessDirectory
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
    @State private var showFilterSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showPasswordConfirmation = false
    @State private var confirmPassword = ""
    @State private var deleteError: String?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("main_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
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
                        
                        Menu {
                            if isLoggedIn {
                                Section("Account") {
                                    Button {
                                        Task {
                                            do {
                                                try viewModel.signOut()
                                                isLoggedIn = false
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
                        Text("You have signed out")
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
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Continue", role: .destructive) {
                    showPasswordConfirmation = true
                }
            } message: {
                Text("Are you sure you want to delete your account? This will permanently delete all your data including your profile, companies, and all associated images. This action cannot be undone.")
            }
            .alert("Confirm Password", isPresented: $showPasswordConfirmation) {
                SecureField("Enter your password", text: $confirmPassword)
                Button("Cancel", role: .cancel) {
                    confirmPassword = ""
                }
                Button("Delete Account", role: .destructive) {
                    Task {
                        do {
                            guard let email = try? AuthenticationManager.shared.getAuthenticatedUser().email else {
                                return
                            }
                            try await viewModel.reauthenticateAndDelete(email: email, password: confirmPassword)
                            isLoggedIn = false
                            showSignInView = true
                        } catch {
                            deleteError = error.localizedDescription
                            confirmPassword = ""
                        }
                    }
                }
            } message: {
                Text("For security reasons, please enter your password to delete your account.")
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
