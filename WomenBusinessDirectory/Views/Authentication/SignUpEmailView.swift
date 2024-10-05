//
//  SignUpEmailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI

struct SignUpEmailView: View {
  @StateObject private var viewModel = SignUpEmailViewModel()
  
  @State var confirmPassword: String = ""
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    VStack {
      Image("firebaseLogo")
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 120)
        .padding(.vertical, 20)
      
      // form fields
      VStack(spacing: 25) {
        InputView(
          text: $viewModel.email,
          title: "Email address",
          placeholder: "name@example.com",
          isSecuredField: false)
        .autocapitalization(.none)
        
        InputView(
          text: $viewModel.fullName,
          title: "Enter your full name",
          placeholder: "John Doe",
          isSecuredField: false)
        
        InputView(
          text: $viewModel.password,
          title: "Enter password",
          placeholder: "Enter your password",
          isSecuredField: true)
        
        ZStack(alignment: .trailing) {
          InputView(
            text: $confirmPassword,
            title: "Confirm password",
            placeholder: "Confirm your password",
            isSecuredField: true)
          
          if !viewModel.password.isEmpty && !confirmPassword.isEmpty {
            if viewModel.password == confirmPassword {
              Image(systemName: "checkmark.circle.fill")
                .imageScale(.large)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemGreen))
            } else {
              Image(systemName: "xmark.circle.fill")
                .imageScale(.large)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemRed))
            }
          }
        }
      }
    } // vstack
    .padding(.horizontal)
    .padding(.top, 12)
    
    
    // sign up button
    Button {
      Task {
        do {
          try await viewModel.singUp()
          return
        } catch {
          print("Failed to sign up: \(error)")
        }
      }
    } label: {
      HStack {
        Text("Sign up")
          .fontWeight(.semibold)
        Image(systemName: "arrow.right")
      }
      .foregroundColor(.white)
      .frame(width: UIScreen.main.bounds.width - 32, height: 48)
    }
    .padding(.vertical, 10)
    .background(Color.yellow)
    .disabled(!formIsValid)
    .opacity(formIsValid ? 1 : 0.5)
    .cornerRadius(8)
    .padding(.top, 20)
    
    Spacer()
    
    Button {
      dismiss()
    } label: {
      HStack {
        Text("Already have an account?")
          .foregroundColor(.gray)
        Text("Sign in")
              .foregroundColor(.purple1)
      }
    }
  }
}

// MARK: - AuthenticationFormProtocol
extension SignUpEmailView: AuthenticationFormProtocol {
  var formIsValid: Bool {
    return !viewModel.email.isEmpty
    && !viewModel.password.isEmpty
    && viewModel.password.count >= 6
    && viewModel.email.contains("@")
    && confirmPassword == viewModel.password
    && !viewModel.fullName.isEmpty
  }
}

#Preview {
  SignUpEmailView()
}
