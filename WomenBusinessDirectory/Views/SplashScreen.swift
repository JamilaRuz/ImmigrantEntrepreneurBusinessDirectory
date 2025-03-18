//
//  SplashScreen.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/4/24.
//

import SwiftUI
import FirebaseAuth

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // Add color scheme environment to detect dark mode
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color("purple1")
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                VStack {
                    LogoView(width: 150, height: 150, cornerRadius: 20)
                    
                    Text("Immigrant\nEntrepreneur Canada")
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        // Adjust text color based on color scheme
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    print("SplashScreen: Animation starting")
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                // Check if user is already signed in
                if let user = Auth.auth().currentUser {
                    print("SplashScreen: User already signed in with UID: \(user.uid)")
                } else {
                    print("SplashScreen: No user is signed in")
                }
                
                print("SplashScreen: Setting timer to transition to ContentView")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("SplashScreen: Timer fired, transitioning to ContentView")
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
} 
