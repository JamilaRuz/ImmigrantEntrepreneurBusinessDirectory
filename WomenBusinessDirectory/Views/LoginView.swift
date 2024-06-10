//
//  LoginView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/6/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
  @State var email: String = ""
  @State var password: String = ""
  @EnvironmentObject var viewModel: AuthViewModel
  
  var body: some View {
    NavigationStack {
      VStack {
        Image("firebaseLogo")
          .resizable()
          .scaledToFill()
          .frame(width: 100, height: 120)
          .padding(.vertical, 20)
        
        //        form fields
        VStack(spacing: 25) {
          InputView(
            text: $email,
            title: "Email address",
            placeholder: "name@example.com",
            isSecuredField: false)
          .autocapitalization(.none)
          InputView(
            text: $password,
            title: "Enter password",
            placeholder: "name@example.com",
            isSecuredField: true)
          .autocapitalization(.none)
          
        } //vstack
        .padding(.horizontal, 20)
        .padding(.top, 12)
        
        // sign in button
        Button {
          Task {
            try await viewModel.signIn(email: email, password: password)
          }
        } label: {
          HStack {
            Text("Sign in")
              .fontWeight(.semibold)
            Image(systemName: "arrow.right")
          }
            .foregroundColor(.white)
            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
        }
        .padding(.vertical, 10)
        .background(Color.green4)
        .cornerRadius(8)
        .padding(.top, 20)
        
        Spacer()
        
        // register button
        
        NavigationLink {
          RegisterView()
            .navigationBarBackButtonHidden(true)
        } label: {
          HStack {
            Text("Don't have an account?")
              .foregroundColor(.gray)
            Text("Register")
              .foregroundColor(.green4)
          }
        }
      }
    }
  }
}

#Preview {
    LoginView()
      .environment(\.modelContext, createPreviewModelContainer().mainContext)
}

