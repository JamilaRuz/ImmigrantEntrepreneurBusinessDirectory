//
//  ContentView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var showSignInView = false  // Changed initial value to false
    @State private var userIsLoggedIn = false
    @StateObject private var directoryListViewModel = DirectoryListViewModel()
    
    var body: some View {
        Group {
            if showSignInView {
                AuthenticationView(showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn)
            } else {
                MainTabView(
                    showSignInView: $showSignInView,
                    userIsLoggedIn: $userIsLoggedIn,
                    directoryListViewModel: directoryListViewModel
                )
            }
        }
        .onAppear {
            // Check authentication state when app appears
            checkAuthState()
        }
        .onChange(of: Auth.auth().currentUser) { user in
            // Update login status whenever auth state changes
            userIsLoggedIn = user != nil
        }
    }
    
    private func checkAuthState() {
        if let user = Auth.auth().currentUser {
            // User is signed in
            userIsLoggedIn = true
            showSignInView = false
        } else {
            // No user is signed in
            userIsLoggedIn = false
            showSignInView = true
        }
    }
}

struct MainTabView: View {
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    @ObservedObject var directoryListViewModel: DirectoryListViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DirectoryListView(viewModel: directoryListViewModel, showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn)
                .tabItem {
                    Label("Directories", systemImage: "newspaper")
                }
                .tag(0)
            
            BookmarkedListView()
                .tabItem {
                    Label("Bookmarked", systemImage: "star.square")
                }
                .tag(1)
            
            EntrepreneursListView()
                .tabItem {
                    Label("Entrepreneurs", systemImage: "person.2.fill")
                }
                .tag(2)
            
            if userIsLoggedIn {
                ProfileView(showSignInView: $showSignInView)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            } else {
                EmptyProfileView(showSignInView: $showSignInView)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
        }
        .accentColor(tabColor)
    }
    
    private var tabColor: Color {
        switch selectedTab {
        case 0:
            return Color.purple1
        case 1:
            return Color.green1
        case 2:
            return Color.orange1
        case 3:
            return Color.pink1
        default:
            return Color.pink1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
