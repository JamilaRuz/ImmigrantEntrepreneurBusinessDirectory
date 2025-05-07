//
//  SignInWithAppleButton.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI
import AuthenticationServices

// Store delegates as static properties to prevent them from being deallocated
private var activeDelegate: SignInWithAppleDelegate?
private var activePresentationContext: SignInWithApplePresentationContext?

struct SignInWithAppleButton: View {
    var onCompletion: (Result<ASAuthorization, Error>) -> Void
    
    var body: some View {
        // Use a fixed height container with the Apple button inside
        ZStack {
            Color.clear // Transparent background
            AppleSignInButton()
        }
        .frame(maxWidth: .infinity)
        // Height is set by parent view
        .onTapGesture {
            print("SignInWithAppleButton: Button tapped")
            performAppleSignIn()
        }
    }
    
    private func performAppleSignIn() {
        print("SignInWithAppleButton: Starting Apple Sign In flow")
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // Generate a nonce for Apple Sign In
        let nonce = AuthenticationManager.shared.startSignInWithAppleFlow()
        print("SignInWithAppleButton: Generated nonce: \(nonce.prefix(10))...")
        
        request.nonce = AuthenticationManager.shared.sha256(nonce)
        print("SignInWithAppleButton: Set hashed nonce on request")
        
        // Create and store the delegate and presentation context
        activeDelegate = SignInWithAppleDelegate(onCompletion: onCompletion)
        activePresentationContext = SignInWithApplePresentationContext()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = activeDelegate
        authorizationController.presentationContextProvider = activePresentationContext
        
        print("SignInWithAppleButton: Performing authorization requests")
        authorizationController.performRequests()
    }
}

// Custom Apple Sign In button to match the app's style
struct AppleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        print("AppleSignInButton: Creating ASAuthorizationAppleIDButton")
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // No updates needed
    }
}

// Delegate to handle Apple Sign In completion
class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let onCompletion: (Result<ASAuthorization, Error>) -> Void
    
    init(onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onCompletion = onCompletion
        super.init()
        print("SignInWithAppleDelegate: Initialized")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("SignInWithAppleDelegate: Authorization completed successfully")
        
        // Store the Apple user ID for later credential state checks
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            print("SignInWithAppleDelegate: Storing Apple user ID: \(userID)")
            UserDefaults.standard.set(userID, forKey: "appleUserID")
            
            // Print additional information for debugging
            if let email = appleIDCredential.email {
                print("SignInWithAppleDelegate: User email: \(email)")
            } else {
                print("SignInWithAppleDelegate: No email provided")
            }
            
            if let fullName = appleIDCredential.fullName {
                print("SignInWithAppleDelegate: User full name: \(fullName)")
            } else {
                print("SignInWithAppleDelegate: No full name provided")
            }
        }
        
        print("SignInWithAppleDelegate: Calling completion handler with success")
        DispatchQueue.main.async {
            self.onCompletion(.success(authorization))
            
            // Clear the static references after completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                activeDelegate = nil
                activePresentationContext = nil
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("SignInWithAppleDelegate: Authorization failed with error: \(error)")
        DispatchQueue.main.async {
            self.onCompletion(.failure(error))
            
            // Clear the static references after completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                activeDelegate = nil
                activePresentationContext = nil
            }
        }
    }
}

// Context provider for Apple Sign In
class SignInWithApplePresentationContext: NSObject, ASAuthorizationControllerPresentationContextProviding {
    override init() {
        super.init()
        print("SignInWithApplePresentationContext: Initialized")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        print("SignInWithApplePresentationContext: Providing presentation anchor")
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else {
            print("SignInWithApplePresentationContext: Warning - Could not find window, using default UIWindow")
            return UIWindow()
        }
        print("SignInWithApplePresentationContext: Found window: \(window)")
        return window
    }
}

struct SignInWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButton { _ in }
            .padding()
            .previewLayout(.sizeThatFits)
    }
} 
