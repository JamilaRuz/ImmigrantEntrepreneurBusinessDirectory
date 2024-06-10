//
//  RegisterView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI
import SwiftData

struct RegisterView: View {
  @State var email: String = ""
  @State var fullName: String = ""
  @State var password: String = ""
  @State var confirmPassword: String = ""
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: AuthViewModel
  
    var body: some View {
      VStack {
        Image("firebaseLogo")
          .resizable()
          .scaledToFill()
          .frame(width: 100, height: 120)
          .padding(.vertical, 20)
        
        //        form fields
        VStack(spacing: 25) {
          InputView(
            text: $email,
            title: "Email address",
            placeholder: "name@example.com",
            isSecuredField: false)
          .autocapitalization(.none)
          InputView(
            text: $fullName,
            title: "Enter your fullname",
            placeholder: "name@example.com",
            isSecuredField: false)

          InputView(
            text: $password,
            title: "Enter password",
            placeholder: "name@example.com",
            isSecuredField: true)
          
          InputView(
            text: $confirmPassword,
            title: "Confirm password",
            placeholder: "Confirm your password",
            isSecuredField: false)
        }
      } //vstack
      .padding(.horizontal)
      .padding(.top, 12)
      
      
      // sign up button
      
      Button {
        Task {
          do {
            try await viewModel.signUp(email: email, password: password, fullName: fullName)
          } catch {
            print("Error signing up: \(error)")
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
      .background(Color.green4)
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
            .foregroundColor(.green4)
        }
      }
    }
}

#Preview {
  RegisterView()
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
