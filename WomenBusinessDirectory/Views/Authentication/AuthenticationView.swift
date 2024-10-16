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
    
    @Binding var showSignInView: Bool
    @State private var navigateToDirectoryList = false
    
    var body: some View {
        NavigationStack {
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
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    } else {
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        isPasswordVisible ? Image(systemName: "eye.slash") : Image(systemName: "eye")
                    }
                    .foregroundColor(.gray)
                    .padding(.trailing)
                }
                .padding()
                
                Button(action: {
                    Task {
                        do {
                            let emailExists = try await viewModel.signIn(email: email, password: password)
                            if emailExists {
                                navigateToDirectoryList = true
                            } else {
                                print("Email does not exist.")
                            }
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
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
                
                Text("or")
                    .foregroundColor(.gray)
                
                //Social media buttons
                
                Button(action: {
                    // Handle Apple sign in
                }) {
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
                .padding(.horizontal)
                
                Button(action: {
                    // Handle Google sign in
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
                    // Handle Facebook sign in
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
                    navigateToDirectoryList = true
                }
                .frame(width: 100, height: 40)
                .foregroundColor(.red)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .navigationDestination(isPresented: $navigateToDirectoryList) {
                    DirectoryListView(viewModel: DirectoryListViewModel(), showSignInView: $showSignInView)
                }
            } //VStack
        } //navigationStack
    }//body
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(showSignInView: .constant(true))
    }
}
