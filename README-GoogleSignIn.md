# Google Sign-In Implementation Guide

This document outlines the steps to implement Google Sign-In for the Women Business Directory app.

## Prerequisites

1. A Firebase project (which you already have set up)
2. Google Sign-In enabled in your Firebase project

## Step 1: Add the GoogleSignIn SDK via Swift Package Manager

1. Open your Xcode project
2. Go to File > Swift Packages > Add Package Dependency
3. Enter the package URL: `https://github.com/google/GoogleSignIn-iOS.git`
4. Select the version you want to use (typically the latest stable version)
5. Add the package to your app target

## Step 2: Configure Google Sign-In in Firebase

1. Go to your [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. In the left sidebar, click on "Authentication"
4. Go to the "Sign-in method" tab
5. Enable "Google" as a sign-in provider
6. Add your app's support email
7. Save the changes
8. Go to "Project settings" > "Your apps" and make sure your iOS app is registered
9. Download the updated `GoogleService-Info.plist` file if prompted
10. Note the Google Web Client ID from your Firebase project settings (you'll need this in Step 3)

## Step 3: Update Info.plist

1. Open your Info.plist file
2. Update the existing CFBundleURLTypes entry for Google Sign-In:
   - Replace `YOUR-CLIENT-ID` with the Google Web Client ID from your Firebase project settings
   - The URL scheme should look like: `com.googleusercontent.apps.123456789-abcdefghijklmnopqrstuvwxyz`
3. If needed, update the `GoogleService-Info.plist` file in your project with the one you downloaded from Firebase

## Step 4: Complete the Implementation in Code

1. Uncomment the import in AuthenticationView.swift:
   ```swift
   import GoogleSignIn
   ```

2. Add the GIDSignIn initialization in WomenBusinessDirectoryApp.swift:
   ```swift
   import GoogleSignIn
   
   // In your App class
   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
       return GIDSignIn.sharedInstance.handle(url)
   }
   ```

3. Update the handleSocialSignIn method in AuthenticationView.swift:
   ```swift
   case "google":
       // Get the client ID from GoogleService-Info.plist
       guard let clientID = FirebaseApp.app()?.options.clientID else {
           self.showAlert = true
           self.alertTitle = "Configuration Error"
           self.alertMessage = "Google Sign In isn't configured correctly. Check your GoogleService-Info.plist file."
           return
       }
       
       // Create Google Sign In configuration
       let config = GIDConfiguration(clientID: clientID)
       GIDSignIn.sharedInstance.configuration = config
       
       // Start the Google sign-in process
       GIDSignIn.sharedInstance.signIn(
           withPresenting: UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
       ) { signInResult, error in
           if let error = error {
               // Handle error
               DispatchQueue.main.async {
                   self.showAlert = true
                   self.alertTitle = "Sign In Error"
                   self.alertMessage = "Failed to sign in with Google: \(error.localizedDescription)"
               }
               return
           }
           
           guard let signInResult = signInResult else { return }
           
           // Extract ID token and access token
           guard let idToken = signInResult.user.idToken?.tokenString,
                 let accessToken = signInResult.user.accessToken.tokenString else {
               // Handle missing token error
               DispatchQueue.main.async {
                   self.showAlert = true
                   self.alertTitle = "Sign In Error"
                   self.alertMessage = "Failed to get Google authentication tokens"
               }
               return
           }
           
           // Sign in with Firebase using the tokens
           Task {
               do {
                   let authResult = try await AuthenticationManager.shared.signInWithGoogle(
                       idToken: idToken,
                       accessToken: accessToken
                   )
                   
                   // Update UI state on success
                   DispatchQueue.main.async {
                       self.userIsLoggedIn = true
                       self.showSignInView = false
                       
                       // Force UI update
                       NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
                   }
               } catch {
                   // Handle Firebase sign in error
                   DispatchQueue.main.async {
                       self.showAlert = true
                       self.alertTitle = "Sign In Error"
                       self.alertMessage = "Failed to sign in with Google: \(error.localizedDescription)"
                   }
               }
           }
       }
   ```

## Step 5: Testing

1. Build and run the app
2. Try signing in with Google
3. Check the Firebase Authentication console to verify the user was created
4. Check Firestore to verify the user document was created

## Troubleshooting

- If sign-in fails, check the console logs for specific error messages
- Verify your Firebase Authentication configuration has Google enabled
- Make sure the URL scheme in Info.plist matches your client ID
- Confirm the GoogleSignIn SDK is properly integrated 