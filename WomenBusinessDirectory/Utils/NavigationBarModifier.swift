//
//  NavigationBarModifier.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/4/24.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    enum RightBarItem {
        case menu(showSignInView: Binding<Bool>, isLoggedIn: Binding<Bool>)
    }
    
    let rightBarItem: RightBarItem
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
                    switch rightBarItem {
                    case .menu(let showSignInView, let isLoggedIn):
                        Menu {
                            if isLoggedIn.wrappedValue {
                                Button("Sign Out") {
                                    isLoggedIn.wrappedValue = false
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showToast = false
                                    }
                                }
                            } else {
                                Button("Sign In") {
                                    showSignInView.wrappedValue = true
                                }
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .imageScale(.large)
                                .foregroundColor(isLoggedIn.wrappedValue ? Color("pink1") : Color.gray)
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
    }
}

extension View {
    func customNavigationBar(showSignInView: Binding<Bool>, isLoggedIn: Binding<Bool>) -> some View {
        self.modifier(NavigationBarModifier(rightBarItem: .menu(showSignInView: showSignInView, isLoggedIn: isLoggedIn)))
    }
}
