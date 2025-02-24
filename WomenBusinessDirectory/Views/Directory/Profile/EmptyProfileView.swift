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
        VStack(spacing: 20) {
            Text("Please log in first to create your profile.")
                .font(.title2)
                .foregroundColor(Color.pink1)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                showSignInView = true // Navigate to AuthenticationView
            }) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(Color.pink1)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.pink1, lineWidth: 1)
                    )
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProfileView(showSignInView: .constant(false))
    }
}
