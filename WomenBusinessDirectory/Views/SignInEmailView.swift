//
//  LoginView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/6/24.
//

import SwiftUI
//import SwiftData

struct SignInEmailView: View {
  
  @StateObject private var viewModel = SignInEmailViewModel()
  @Binding var showSignInView: Bool
  
  @State private var formIsValid = false
  
  var body: some View {
    VStack {
      Image("firebaseLogo")
        .resizable()
        .scaledToFill()
        .overlay {
          LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5),.clear, Color.green4, Color.green2]), startPoint: .top, endPoint: .bottom)
        }
        .frame(width: 100, height: 150)
        .padding(.vertical, 20)
      
      //        form fields
      VStack(spacing: 25) {
        InputView(
          text: $viewModel.email,
          title: "Email address",
          placeholder: "name@example.com",
          isSecuredField: false)
        .autocapitalization(.none)
        InputView(
          text: $viewModel.password,
          title: "Enter password",
          placeholder: "password",
          isSecuredField: true)
        .autocapitalization(.none)
        
      } //vstack
      .padding(.horizontal, 20)
      .padding(.top, 12)
      
      // sign in button
      Button {
        Task {
            do {
              try await viewModel.singUp()
              showSignInView = false
              return
            } catch {
              print("Failed to sign up: \(error)")
            }
          
            do {
              try await viewModel.singIn()
              showSignInView = false
              return
            } catch {
              print("Failed to sign in: \(error)")
            }
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
      .cornerRadius(8)
      .background(Color.green4)
//      .disabled(!formIsValid)
//      .opacity(formIsValid ? 1 : 0.5)
      .padding(.vertical, 10)
      .padding(.top, 20)
      
      Spacer()
      
      // register button
      
      NavigationLink {
        SignUp()
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

#Preview {
  NavigationStack {
    SignInEmailView(showSignInView: .constant(true))
  }
}

