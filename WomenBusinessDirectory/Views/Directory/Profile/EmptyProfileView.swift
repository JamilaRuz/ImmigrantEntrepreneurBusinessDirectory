//
//  EmptyView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/16/24.
//

import SwiftUI

struct EmptyProfileView: View {
    @Binding var showSignInView: Bool // Binding to control navigation to AuthenticationView

    var body: some View {
        VStack(spacing: 16) {
            Text("Please sign in first\nto create your profile.")
                .font(.body)
                .foregroundColor(Color.pink1)
                .multilineTextAlignment(.center)
                
            Button(action: {
                // Reset the skipped authentication state when user explicitly chooses to sign in
                UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
                showSignInView = true // Navigate to AuthenticationView
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(Color.pink1)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(Color.white)
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

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProfileView(showSignInView: .constant(false))
    }
}
