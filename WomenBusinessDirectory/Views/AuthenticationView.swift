//
//  AuthenticationView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/18/24.
//

import SwiftUI

struct AuthenticationView: View {
  
  @Binding var showSignInView: Bool
  
  var body: some View {
    VStack {
      NavigationLink {
        SignInEmailView(showSignInView: $showSignInView)
      } label: {
        Text("Sign In With Apple")
          .font(.headline)
          .foregroundColor(.white)
          .frame(height: 55)
          .frame(maxWidth: .infinity)
          .background(Color.black)
          .cornerRadius(8)
      }
      NavigationLink {
        SignInEmailView(showSignInView: $showSignInView)
      } label: {
        Text("Sign In With Google")
          .font(.headline)
          .foregroundColor(.white)
          .frame(height: 55)
          .frame(maxWidth: .infinity)
          .background(Color.orange)
          .cornerRadius(8)
      }
      NavigationLink {
        SignInEmailView(showSignInView: $showSignInView)
      } label: {
        Text("Sign In With Email")
          .font(.headline)
          .foregroundColor(.white)
          .frame(height: 55)
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .cornerRadius(8)
      }
      Spacer()
    }
    .padding()
    .navigationTitle("Sign In")
  }
}

#Preview {
  NavigationStack {
    AuthenticationView(showSignInView: .constant(true))
  }
}
