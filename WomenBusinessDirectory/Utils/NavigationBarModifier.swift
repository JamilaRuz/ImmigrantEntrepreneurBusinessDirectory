//
//  NavigationBarModifier.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/4/24.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    @Binding var showSignInView: Bool
    @Binding var isLoggedIn: Bool // Use binding to update login status
    @State private var showToast = false

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
                    Menu {
                        if isLoggedIn {
                            Button("Sign Out") {
                                isLoggedIn = false
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
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
                .padding(.top, 50) // Adjust based on your layout
            )
    }
}

extension View {
    func customNavigationBar(showSignInView: Binding<Bool>, isLoggedIn: Binding<Bool>) -> some View {
        self.modifier(NavigationBarModifier(showSignInView: showSignInView, isLoggedIn: isLoggedIn))
    }
}
