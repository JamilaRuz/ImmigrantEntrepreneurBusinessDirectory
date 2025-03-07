//
//  ContentView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var showSignInView = false
    @State private var userIsLoggedIn = false
    @StateObject private var directoryListViewModel = DirectoryListViewModel()
    
    // Add a state variable to force view refresh
    @State private var forceRefresh: Bool = false
    
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
            print("ContentView: onAppear - Checking auth state")
            checkAuthState()
            
            // Add notification observer for sign-in events
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UserDidSignIn"), object: nil, queue: .main) { _ in
                print("ContentView: Received UserDidSignIn notification")
                DispatchQueue.main.async {
                    self.userIsLoggedIn = true
                    self.showSignInView = false
                    self.forceRefresh.toggle() // Force view refresh
                    print("ContentView: Updated state after notification - userIsLoggedIn: \(self.userIsLoggedIn), showSignInView: \(self.showSignInView)")
                }
            }
        }
        .onDisappear {
            // Remove notification observer
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidSignIn"), object: nil)
        }
        .onChange(of: Auth.auth().currentUser) { _, newUser in
            // Update login status whenever auth state changes
            print("ContentView: Auth state changed - User: \(newUser?.uid ?? "nil")")
            userIsLoggedIn = newUser != nil
            if userIsLoggedIn {
                showSignInView = false
            }
        }
        .id(forceRefresh) // Force view to refresh when this changes
    }
    
    private func checkAuthState() {
        if let user = Auth.auth().currentUser {
            // User is signed in
            print("ContentView: User is signed in with UID: \(user.uid)")
            userIsLoggedIn = true
            showSignInView = false
        } else {
            // No user is signed in
            print("ContentView: No user is signed in")
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
    
    // Add a state variable to force view refresh
    @State private var forceRefresh: Bool = false
    
    init(showSignInView: Binding<Bool>, userIsLoggedIn: Binding<Bool>, directoryListViewModel: DirectoryListViewModel) {
        self._showSignInView = showSignInView
        self._userIsLoggedIn = userIsLoggedIn
        self._directoryListViewModel = ObservedObject(wrappedValue: directoryListViewModel)
        
        // Configure tab bar appearance to be non-transparent
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        
        print("MainTabView: Initialized with userIsLoggedIn = \(userIsLoggedIn.wrappedValue)")
    }
    
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
        .onAppear {
            print("MainTabView: onAppear - userIsLoggedIn = \(userIsLoggedIn)")
            
            // Add notification observer for sign-in events
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UserDidSignIn"), object: nil, queue: .main) { _ in
                print("MainTabView: Received UserDidSignIn notification")
                DispatchQueue.main.async {
                    self.forceRefresh.toggle() // Force view refresh
                    print("MainTabView: Updated state after notification - userIsLoggedIn: \(self.userIsLoggedIn)")
                }
            }
        }
        .onDisappear {
            // Remove notification observer
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidSignIn"), object: nil)
        }
        .id(forceRefresh) // Force view to refresh when this changes
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
