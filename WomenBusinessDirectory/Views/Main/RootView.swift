//
//  RootView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/19/24.
//

import SwiftUI

struct RootView: View {
  
  @State private var showSignInView = false
  
  var body: some View {
    ZStack {
      NavigationStack {
        ProfileView(showSignInView: $showSignInView)
      }
    }
    .onAppear {
      let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
      self.showSignInView = authUser == nil
    }
    .fullScreenCover(isPresented: $showSignInView) {
      NavigationStack {
        AuthenticationView(showSignInView: $showSignInView)
      }
    }
  }
}

#Preview {
  RootView()
}
