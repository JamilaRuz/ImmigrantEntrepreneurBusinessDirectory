//
//  RootView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @Binding var showSignInView: Bool
    @State private var navigateToDirectoryList = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Immigrant \nEntrepreneur Canada")
                    .font(.largeTitle)
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    // Handle continue action
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Text("or")
                    .foregroundColor(.gray)
                
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

            }
            .padding()
            .navigationDestination(isPresented: $navigateToDirectoryList) {
                DirectoryListView(viewModel: DirectoryListViewModel(), showSignInView: $showSignInView)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showSignInView: .constant(true))
    }
}
