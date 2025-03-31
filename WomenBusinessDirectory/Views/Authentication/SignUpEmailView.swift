//
//  SignUpEmailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpEmailView: View {
  @StateObject private var viewModel = SignUpEmailViewModel()
  @Environment(\.dismiss) var dismiss
  @Environment(\.presentationMode) var presentationMode
  @Binding var showSignInView: Bool
  
  @State var confirmPassword: String = ""
  @State private var showAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  @State private var isSuccess = false
  @State private var isLoading = false
  
  func handleAuthError(_ error: Error) {
      alertTitle = "Please Note"
      alertMessage = FirebaseErrorHandler.handleError(error)
  }
  
  var body: some View {
    ZStack {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                LogoView(width: 100, height: 120)
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
                .padding(.horizontal)
                .padding(.top, 12)
                
                // sign up button
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isLoading = true
                    Task {
                        do {
                            try await viewModel.signUp()
                            // After successful signup, show verification message
                            isSuccess = true
                            alertTitle = "Verification Email Sent"
                            alertMessage = "Please check your email and verify your account before signing in."
                            showAlert = true
                            // Don't automatically sign in - require email verification first
                        } catch {
                            isSuccess = false
                            handleAuthError(error)
                            showAlert = true
                        }
                        isLoading = false
                    }
                } label: {
                    Text("Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .cornerRadius(10)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer(minLength: 30)
                
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
                .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        
        // Overlay loading indicator
        if isLoading {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
  SignUpEmailView(showSignInView: .constant(false))
}
