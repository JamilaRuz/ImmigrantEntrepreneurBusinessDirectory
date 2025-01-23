//
//  AuthenticationView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading = false
    
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool // Use binding to update login status


    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Text("Immigrant \nEntrepreneur Canada")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Image("main_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Log in or Sign up")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            isPasswordVisible ? Image(systemName: "eye.slash") : Image(systemName: "eye")
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
                                    print("Email does not exist.")
                                }
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                            isLoading = false
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: SignUpEmailView()) {
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
                
                Button(action: {
                    // Handle Apple sign in
                    // Add delay to simulate API call
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    }
                }) {
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
                .padding(.horizontal)
                
                Button(action: {
                    isLoading = true
                    // Handle Google sign in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }) {
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
                .padding(.horizontal)
                
                Button(action: {
                    isLoading = true
                    // Handle Facebook sign in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }) {
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
                .padding(.horizontal)
                
                Spacer()
                
                Button("Skip") {
                    showSignInView = false
                    userIsLoggedIn = false // Ensure user is not logged in
                }
                .frame(width: 100, height: 40)
                .foregroundColor(.red)
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
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    } // body
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(showSignInView: .constant(true), userIsLoggedIn: .constant(false))
    }
}
