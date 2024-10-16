//
//  NavigationBarModifier.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/4/24.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    @Binding var showSignInView: Bool
    var isLoggedIn: Bool // Add a property to track login status
    
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
                    NavigationLink(destination: ProfileView(showSignInView: $showSignInView)) {
                        Image(systemName: "person.crop.circle")
                            .imageScale(.large)
                            .foregroundColor(isLoggedIn ? Color("pink1") : Color.gray) // Change color based on login status
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func customNavigationBar(showSignInView: Binding<Bool>, isLoggedIn: Bool) -> some View {
        self.modifier(NavigationBarModifier(showSignInView: showSignInView, isLoggedIn: isLoggedIn))
    }
}
