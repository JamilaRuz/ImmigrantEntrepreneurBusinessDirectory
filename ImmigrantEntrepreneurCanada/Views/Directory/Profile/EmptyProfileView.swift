//
//  EmptyView.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 10/16/24.
//

import SwiftUI

struct EmptyProfileView: View {
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    
    // Add color scheme environment to detect dark mode
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Text("Please sign in first\nto create your profile.")
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white : Color.pink1)
                .multilineTextAlignment(.center)
                
            Button(action: {
                // Reset the skipped authentication state when user explicitly chooses to sign in
                UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
                showSignInView = true // Navigate to AuthenticationView
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : Color.pink1)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(colorScheme == .dark ? Color.gray : Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: -30)
    }
}

#Preview {
    EmptyProfileView(showSignInView: .constant(false), userIsLoggedIn: .constant(false))
}
