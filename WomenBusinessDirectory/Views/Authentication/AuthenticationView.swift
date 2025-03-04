//
//  AuthenticationView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool

    func handleAuthError(_ error: Error) {
        showAlert = true
        alertTitle = "Sign In Error"
        
        if let errorCode = AuthErrorCode(rawValue: (error as NSError).code) {
            switch errorCode {
            case .wrongPassword:
                alertMessage = "Your email or password is incorrect. Please try again."
            case .invalidEmail:
                alertMessage = "Please enter a valid email address."
            case .userNotFound:
                alertMessage = "No account exists with this email. Please sign up first."
            case .tooManyRequests:
                alertMessage = "Too many unsuccessful attempts. Please try again later."
            case .networkError:
                alertMessage = "Network error. Please check your internet connection."
            case .invalidCredential:
                alertMessage = "Your email or password is incorrect. Please try again."
            default:
                alertMessage = "Your email or password is incorrect. Please try again."
            }
        } else {
            alertMessage = "Your email or password is incorrect. Please try again."
        }
    }

    func handleSocialSignIn(provider: String) {
        isLoading = true
        Task {
            do {
                switch provider {
                case "apple":
                    // Handle Apple sign in
                    break
                case "google":
                    // Handle Google sign in
                    break
                case "facebook":
                    // Handle Facebook sign in
                    break
                default:
                    break
                }
            }
            isLoading = false
        }
    }

    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Text("Immigrant \nEntrepreneur Canada")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                LogoView(width: 100, height: 100)
                
                Text("Sign in or Sign up")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            isPasswordVisible ? Image(systemName: "eye") : Image(systemName: "eye.slash")
                        }
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        isLoading = true
                        Task {
                            do {
                                let emailExists = try await viewModel.signIn(email: email, password: password)
                                if emailExists {
                                    userIsLoggedIn = true
                                    showSignInView = false
                                } else {
                                    showAlert = true
                                    alertTitle = "Sign In Error"
                                    alertMessage = "No account exists with this email. Please sign up first."
                                }
                            } catch {
                                handleAuthError(error)
                            }
                            isLoading = false
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange1)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    NavigationLink(destination: SignUpEmailView(showSignInView: $showSignInView)) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            Text("Sign Up")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                    
                }
                
                Text("or")
                    .foregroundColor(.gray)
                
                // Social media buttons
                Group {
                    Button(action: {}) {
                        ZStack {
                            HStack {
                                Image("apple_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Continue with Apple")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                    }
                    .disabled(true)
                    
                    Button(action: {}) {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .disabled(true)
                    
                    Button(action: {}) {
                        HStack {
                            Image("facebook_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Facebook")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .disabled(true)
                }
                .padding(.horizontal)
                .opacity(0.6)
                .overlay(
                    Text("Coming Soon")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                )
                
                Spacer()
                
                Button("Skip") {
                    showSignInView = false
                    userIsLoggedIn = false // Ensure user is not logged in
                }
                .frame(width: 100, height: 40)
                .foregroundColor(.orange1)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            } // ScrollView
            
            // Overlay loading indicator
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .ignoresSafeArea()
            }
        }
    } // body
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(showSignInView: .constant(true), userIsLoggedIn: .constant(false))
    }
}
