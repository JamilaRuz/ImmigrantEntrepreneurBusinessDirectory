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
    @State private var showToast = false
    @State private var showFilterSheet = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("main_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showFilterSheet = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .imageScale(.large)
                                .foregroundColor(Color("pink1"))
                        }
                        
                        Menu {
                            if isLoggedIn {
                                Section("Email Functions") {
                                    Button {
                                        Task {
                                            try? await viewModel.resetPassword()
                                        }
                                    } label: {
                                        Label("Reset Password", systemImage: "person.badge.key")
                                    }
                                    
                                    Button {
                                        Task {
                                            try? await viewModel.updatePassword()
                                        }
                                    } label: {
                                        Label("Update Password", systemImage: "lock.circle")
                                    }
                                }
                                
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
                                        Task {
                                            do {
                                                try await viewModel.deleteAccount()
                                                isLoggedIn = false
                                                showSignInView = true
                                            } catch {
                                                print("Error deleting account: \(error)")
                                            }
                                        }
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
                            Image(systemName: "person.crop.circle")
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
    }
}

extension View {
    func customNavigationBar(showSignInView: Binding<Bool>, isLoggedIn: Binding<Bool>) -> some View {
        self.modifier(NavigationBarModifier(
            showSignInView: showSignInView,
            isLoggedIn: isLoggedIn
        ))
    }
}
