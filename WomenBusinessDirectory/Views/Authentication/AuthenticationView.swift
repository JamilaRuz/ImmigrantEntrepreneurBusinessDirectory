//
//  AuthenticationView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import Firebase

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
    
    // Get the color scheme from the environment to detect dark mode
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let onSuccessfullySignedIn: (() -> Void)?

    func handleAuthError(_ error: Error) {
        alertTitle = "Sign In Error"
        alertMessage = FirebaseErrorHandler.handleError(error)
        showAlert = true
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
                    try await handleGoogleSignIn()
                case "facebook":
                    // Handle Facebook sign in
                    break
                default:
                    throw NSError(domain: "com.womenbusinessdirectory", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Unsupported provider"])
                }
            } catch {
                print("Error during social sign in: \(error)")
                await MainActor.run {
                    self.showAlert = true
                    self.alertTitle = "Error"
                    self.alertMessage = "An unexpected error occurred. Please try again."
                    self.isLoading = false
                }
            }
            
            // Only set isLoading to false here for non-Google providers
            // (Google provider handles this within its own completion handler)
            if provider != "google" {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func handleGoogleSignIn() async throws {
        // Setup defer to ensure loading indicator is reset at the end of function execution
        defer {
            Task {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        // Get the client ID from GoogleService-Info.plist
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "com.womenbusinessdirectory", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Google Sign In isn't configured correctly. Check your GoogleService-Info.plist file."])
        }
        
        // Create Google Sign In configuration
        let config = GIDConfiguration(clientID: clientID)
        
        // Find the rootViewController to present the sign-in screen
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "com.womenbusinessdirectory", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Could not find a view controller to present the sign-in screen."])
        }
        
        // Start the Google sign-in process
        do {
            GIDSignIn.sharedInstance.configuration = config
            
            // Use try-await pattern with continuation to make catch block reachable
            let signInResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let signInResult = signInResult else {
                        continuation.resume(throwing: NSError(domain: "com.womenbusinessdirectory", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Failed to get sign-in result from Google."]))
                        return
                    }
                    
                    continuation.resume(returning: signInResult)
                }
            }
            
            // Now we can use the result safely since any errors would have been caught
            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw NSError(domain: "com.womenbusinessdirectory", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Failed to get Google ID token."])
            }
            
            // Get access token
            let accessToken = signInResult.user.accessToken.tokenString
            
            // Sign in with Firebase using the tokens
            let authResult = try await AuthenticationManager.shared.signInWithGoogle(
                idToken: idToken,
                accessToken: accessToken
            )
            
            // Update UI state on success
            print("Successfully signed in with Google: \(authResult.email ?? "no email")")
            await MainActor.run {
                self.userIsLoggedIn = true
                self.showSignInView = false

                if let onSuccessfullySignedIn = onSuccessfullySignedIn {
                    onSuccessfullySignedIn()
                } else {
                    // Force UI update by posting a notification
                    NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
                }
            }
            
        } catch {
            // This catch block is now reachable
            print("Google sign in error: \(error)")
            await MainActor.run {
                self.showAlert = true
                self.alertTitle = "Sign In Error"
                self.alertMessage = "Failed to sign in with Google: \(error.localizedDescription)"
            }
            
            // Re-throw the error to be caught by the outer catch block
            throw error
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

                                    if let onSuccessfullySignedIn = onSuccessfullySignedIn {
                                        onSuccessfullySignedIn()
                                    } else {
                                        // Force UI update by posting a notification
                                        NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
                                    }
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
        NavigationStack {
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
                                    .padding(.vertical, 15)
                                    .padding(.horizontal)
                                    .frame(height: 50)
                                    .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color(.systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(colorScheme == .dark ? 0.5 : 0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                                
                                ZStack(alignment: .trailing) {
                                    if isPasswordVisible {
                                        TextField("Password", text: $password)
                                            .autocapitalization(.none)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .textContentType(.none)
                                            .padding(.vertical, 15)
                                            .padding(.horizontal)
                                            .frame(height: 50)
                                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color(.systemBackground))
                                            .cornerRadius(8)
                                    } else {
                                        SecureField("Password", text: $password)
                                            .autocapitalization(.none)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .textContentType(.none)
                                            .padding(.vertical, 15)
                                            .padding(.horizontal)
                                            .frame(height: 50)
                                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color(.systemBackground))
                                            .cornerRadius(8)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        isPasswordVisible ? Image(systemName: "eye") : Image(systemName: "eye.slash")
                                    }
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(colorScheme == .dark ? 0.5 : 0.3), lineWidth: 1)
                                )
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
                                                
                                                if let onSuccessfullySignedIn = onSuccessfullySignedIn {
                                                    onSuccessfullySignedIn()
                                                } else {
                                                    // Force UI update by posting a notification
                                                    NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
                                                }
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
                                        .foregroundColor(colorScheme == .dark ? .white : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50) // Increased height to match Apple button
                                }
                                .background(colorScheme == .dark ? Color.gray : Color.orange1)
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
                                // Apple Sign In Button - conditional rendering based on color scheme
                                if colorScheme == .dark {
                                    // Custom gray wrapper for dark mode
                                    ZStack {
                                        // Gray background
                                        Rectangle()
                                            .fill(Color.gray)
                                            .cornerRadius(8)
                                        
                                        // White SignInWithAppleButton
                                        SignInWithAppleButton { result in
                                            handleAppleSignInCompletion(result: result)
                                        }
                                        .signInWithAppleButtonStyle(.white)
                                        .cornerRadius(6) // Slightly smaller to fit within the gray background
                                        .padding(1)      // Small padding to show gray edge
                                    }
                                    .frame(height: 50)
                                    .padding(.horizontal)
                                } else {
                                    // Standard Apple Sign In Button for light mode
                                    SignInWithAppleButton { result in
                                        handleAppleSignInCompletion(result: result)
                                    }
                                    .signInWithAppleButtonStyle(.black)
                                    .frame(height: 50)
                                    .padding(.horizontal)
                                }
                                
                                // Google Sign In Button - styled to match Apple button
                                Button(action: {
                                    handleSocialSignIn(provider: "google")
                                }) {
                                    HStack {
                                        Image("google_logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(.trailing, 4)
                                        Text("Continue with Google")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                }
                                .background(colorScheme == .dark ? Color.gray : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .padding(.horizontal)
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
                            // Set skipped authentication state
                            UserDefaults.standard.set(true, forKey: "hasSkippedAuthentication")
                            userIsLoggedIn = false
                            showSignInView = false
                            dismiss()
                        }
                        .frame(width: 100, height: 40)
                        .foregroundColor(colorScheme == .dark ? .white : .orange1)
                        .background(colorScheme == .dark ? Color.gray : Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .frame(width: geometry.size.width)
                    .padding(.bottom, 20)
                    .background(Color.white.opacity(0.01))
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
            .ignoresSafeArea(.keyboard)
            .onAppear {
                print("AuthenticationView: onAppear")
                NotificationCenter.default.addObserver(forName: NSNotification.Name("UserDidSignIn"), object: nil, queue: .main) { _ in
                    print("AuthenticationView: Received UserDidSignIn notification")
                    DispatchQueue.main.async {
                        self.userIsLoggedIn = true
                        self.showSignInView = false
                        self.forceRefresh.toggle()
                        print("AuthenticationView: Updated state after notification - userIsLoggedIn: \(self.userIsLoggedIn), showSignInView: \(self.showSignInView)")
                    }
                }
            }
            .onDisappear {
                print("AuthenticationView: onDisappear")
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidSignIn"), object: nil)
            }
            .id(forceRefresh)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(showSignInView: .constant(true), userIsLoggedIn: .constant(false)) { }
    }
}
