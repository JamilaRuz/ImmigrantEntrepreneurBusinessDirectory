//
//  AuthenticationView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

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
    
    // Add a state variable to force view refresh
    @State private var forceRefresh: Bool = false

    func handleAuthError(_ error: Error) {
        showAlert = true
        alertTitle = "Sign In Error"
        
        // Check for email verification error
        let nsError = error as NSError
        if nsError.domain == "EmailVerificationError" && nsError.code == 1001 {
            alertTitle = "Email Not Verified"
            alertMessage = nsError.localizedDescription
            // Add option to resend verification email
            alertMessage += "\n\nWould you like to resend the verification email?"
            return
        }
        
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
                    // Apple sign in is handled by the SignInWithAppleButton
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
    
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) {
        print("Apple Sign In completion handler called with result: \(result)")
        
        switch result {
        case .success(let authorization):
            print("Apple Sign In authorization successful")
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                print("Got Apple ID credential: \(appleIDCredential)")
                
                if let appleIDToken = appleIDCredential.identityToken {
                    print("Got Apple ID token")
                    
                    if let idTokenString = String(data: appleIDToken, encoding: .utf8) {
                        print("Converted token to string: \(idTokenString.prefix(10))...")
                        
                        // Get the nonce from the AuthenticationManager
                        guard let nonce = AuthenticationManager.shared.currentNonce else {
                            print("Invalid state: A login callback was received, but no login request was sent.")
                            showAlert = true
                            alertTitle = "Sign In Error"
                            alertMessage = "Invalid state: A login callback was received, but no login request was sent."
                            return
                        }
                        
                        print("Got nonce: \(nonce.prefix(10))...")
                        
                        // Sign in with Firebase using the Apple ID token
                        Task {
                            do {
                                isLoading = true
                                print("Starting Firebase sign in with Apple...")
                                let authDataResult = try await AuthenticationManager.shared.signInWithApple(idTokenString: idTokenString, nonce: nonce)
                                print("Firebase sign in with Apple successful: \(authDataResult)")
                                
                                // Ensure we're on the main thread when updating UI state
                                DispatchQueue.main.async {
                                    userIsLoggedIn = true
                                    showSignInView = false
                                    print("Updated UI state: userIsLoggedIn=\(userIsLoggedIn), showSignInView=\(showSignInView)")
                                    
                                    // Force UI update by posting a notification
                                    NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
                                }
                            } catch {
                                print("Firebase sign in with Apple failed with error: \(error)")
                                
                                // Ensure we're on the main thread when updating UI state
                                DispatchQueue.main.async {
                                    showAlert = true
                                    alertTitle = "Sign In Error"
                                    alertMessage = "Failed to sign in with Apple: \(error.localizedDescription)"
                                }
                            }
                            
                            // Ensure we're on the main thread when updating UI state
                            DispatchQueue.main.async {
                                isLoading = false
                            }
                        }
                    } else {
                        print("Failed to convert token to string")
                        showAlert = true
                        alertTitle = "Sign In Error"
                        alertMessage = "Failed to get Apple ID token"
                    }
                } else {
                    print("Apple ID token is nil")
                    showAlert = true
                    alertTitle = "Sign In Error"
                    alertMessage = "Failed to get Apple ID token"
                }
            } else {
                print("Failed to get Apple ID credential")
                showAlert = true
                alertTitle = "Sign In Error"
                alertMessage = "Failed to get Apple ID credential"
            }
        case .failure(let error):
            print("Apple Sign In failed with error: \(error)")
            showAlert = true
            alertTitle = "Sign In Error"
            alertMessage = "Failed to sign in with Apple: \(error.localizedDescription)"
        }
    }

    var body: some View {
        // Use a GeometryReader to get the full screen size
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main content in ScrollView
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Text("Immigrant \nEntrepreneur Canada")
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.top, 30)
                        
                        LogoView(width: 100, height: 100)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        
                        Text("Sign in or Sign up")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 10)
                        
                        VStack(spacing: 10) {
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
                            
                            // Add Forgot Password button
                            HStack {
                                Spacer()
                                Button(action: {
                                    if email.isEmpty {
                                        showAlert = true
                                        alertTitle = "Email Required"
                                        alertMessage = "Please enter your email address to reset your password."
                                    } else {
                                        isLoading = true
                                        Task {
                                            do {
                                                try await AuthenticationManager.shared.resetPassword(email: email)
                                                showAlert = true
                                                alertTitle = "Password Reset Email Sent"
                                                alertMessage = "Check your email for instructions to reset your password."
                                            } catch {
                                                showAlert = true
                                                alertTitle = "Password Reset Failed"
                                                alertMessage = "Failed to send password reset email. Please check your email address and try again."
                                                print("Password reset error: \(error)")
                                            }
                                            isLoading = false
                                        }
                                    }
                                }) {
                                    Text("Forgot Password?")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing)
                            }
                            .padding(.bottom, 5)
                            
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
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50) // Increased height to match Apple button
                            }
                            .background(Color.orange1)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .alert(isPresented: $showAlert) {
                                // Check if this is a verification error
                                if alertTitle == "Email Not Verified" {
                                    return Alert(
                                        title: Text(alertTitle),
                                        message: Text(alertMessage),
                                        primaryButton: .default(Text("Resend Email")) {
                                            // Resend verification email
                                            isLoading = true
                                            Task {
                                                do {
                                                    try await viewModel.resendVerificationEmail()
                                                    showAlert = true
                                                    alertTitle = "Verification Email Sent"
                                                    alertMessage = "Please check your inbox for the verification link."
                                                } catch {
                                                    showAlert = true
                                                    alertTitle = "Error"
                                                    alertMessage = "Failed to send verification email. Please try again later."
                                                }
                                                isLoading = false
                                            }
                                        },
                                        secondaryButton: .cancel(Text("OK"))
                                    )
                                } else {
                                    return Alert(
                                        title: Text(alertTitle),
                                        message: Text(alertMessage),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                            }
                            
                            NavigationLink(destination: SignUpEmailView(showSignInView: $showSignInView)) {
                                HStack {
                                    Text("Don't have an account?")
                                        .foregroundColor(.gray)
                                    Text("Sign Up")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            
                        }
                        
                        Text("or")
                            .foregroundColor(.gray)
                            .padding(.vertical, 5)
                        
                        // Social media buttons with improved spacing
                        VStack(spacing: 12) { // Add spacing between buttons
                            // Apple Sign In Button
                            SignInWithAppleButton { result in
                                handleAppleSignInCompletion(result: result)
                            }
                            .frame(height: 50)
                            .padding(.horizontal)
                            
                            // Google Sign In Button - styled to match Apple button
                            Button(action: {}) {
                                HStack {
                                    Image("google_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.trailing, 4)
                                    Text("Continue with Google")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .disabled(true)
                            .opacity(0.6)
                            .overlay(
                                Text("Coming Soon")
                                    .foregroundColor(.gray)
                            )
                            
                            // Facebook Sign In Button - styled to match Apple button
                            Button(action: {}) {
                                HStack {
                                    Image("facebook_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.trailing, 4)
                                    Text("Continue with Facebook")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .disabled(true)
                            .opacity(0.6)
                            .overlay(
                                Text("Coming Soon")
                                    .foregroundColor(.gray)
                            )
                        }
                        .padding(.bottom, 10) // Add padding at the bottom of the button group
                        
                        // Add padding at the bottom to ensure content doesn't get hidden behind the Skip button
                        Spacer()
                            .frame(height: 60) // Reduced from 80 to 60
                    }
                    .frame(minHeight: geometry.size.height - 80) // Ensure content fills the screen minus space for Skip button
                } // ScrollView
                
                // Skip button - anchored to the bottom
                VStack {
                    Button("Skip") {
                        showSignInView = false
                        userIsLoggedIn = false // Ensure user is not logged in
                        
                        // Save the skipped authentication state in UserDefaults
                        UserDefaults.standard.set(true, forKey: "hasSkippedAuthentication")
                    }
                    .frame(width: 100, height: 40)
                    .foregroundColor(.orange1)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .frame(width: geometry.size.width)
                .padding(.bottom, 20)
                .background(Color.white.opacity(0.01)) // Nearly transparent background to capture taps
            }
            
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
        .ignoresSafeArea(.keyboard) // Prevent keyboard from pushing content up
        .onAppear {
            print("AuthenticationView: onAppear")
            // Add notification observer for sign-in events
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UserDidSignIn"), object: nil, queue: .main) { _ in
                print("AuthenticationView: Received UserDidSignIn notification")
                DispatchQueue.main.async {
                    self.userIsLoggedIn = true
                    self.showSignInView = false
                    self.forceRefresh.toggle() // Force view refresh
                    print("AuthenticationView: Updated state after notification - userIsLoggedIn: \(self.userIsLoggedIn), showSignInView: \(self.showSignInView)")
                }
            }
        }
        .onDisappear {
            print("AuthenticationView: onDisappear")
            // Remove notification observer
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidSignIn"), object: nil)
        }
        .id(forceRefresh)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(showSignInView: .constant(true), userIsLoggedIn: .constant(false))
    }
}
