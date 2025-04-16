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
            
            // Check if user has previously skipped authentication
            let hasSkippedAuth = UserDefaults.standard.bool(forKey: "hasSkippedAuthentication")
            showSignInView = !hasSkippedAuth
            
            print("ContentView: User has skipped authentication: \(hasSkippedAuth)")
        }
    }
}

struct MainTabView: View {
    @Binding var showSignInView: Bool
    @Binding var userIsLoggedIn: Bool
    @ObservedObject var directoryListViewModel: DirectoryListViewModel
    @State private var selectedTab = 0
    @ObservedObject private var completionManager = ProfileCompletionManager.shared
    @State private var shouldCheckProfileCompletion = false
    @State private var hasPerformedInitialCheck = false
    
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
            
            BookmarkedListView(showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn)
                .tabItem {
                    Label("Bookmarked", systemImage: "star.square")
                }
                .tag(1)
            
            EntrepreneursListView(showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn)
                .tabItem {
                    Label("Entrepreneurs", systemImage: "person.2.fill")
                }
                .tag(2)
            
            if userIsLoggedIn {
                ProfileView(showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            } else {
                EmptyProfileView(showSignInView: $showSignInView, userIsLoggedIn: $userIsLoggedIn)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
        }
        .accentColor(tabColor)
        .onChange(of: userIsLoggedIn) { _, _ in
            print("MainTabView: userIsLoggedIn changed to: \(userIsLoggedIn)")
            shouldCheckProfileCompletion = true
        }
        .onAppear {
            print("MainTabView: onAppear - userIsLoggedIn = \(userIsLoggedIn)")
            
            // Check profile completion status on first appear
            if !hasPerformedInitialCheck && userIsLoggedIn {
                hasPerformedInitialCheck = true
                shouldCheckProfileCompletion = true
            }
            
            // Add notification observer for sign-in events
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UserDidSignIn"), object: nil, queue: .main) { _ in
                print("MainTabView: Received UserDidSignIn notification")
                DispatchQueue.main.async {
                    self.forceRefresh.toggle() // Force view refresh
                    shouldCheckProfileCompletion = true
                    print("MainTabView: Updated state after notification - userIsLoggedIn: \(self.userIsLoggedIn)")
                }
            }
            
            // Listen for profile completion status changes
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ProfileCompletionStatusChanged"), object: nil, queue: .main) { notification in
                if let isComplete = notification.userInfo?["isComplete"] as? Bool {
                    // Always update the tab based on completion status
                    if !isComplete {
                        // If profile is incomplete, direct user to Profile tab
                        selectedTab = 3
                    } else if selectedTab == 3 {
                        // If we're on the profile tab and profile is complete, 
                        // redirect to Directory tab
                        selectedTab = 0
                    }
                }
            }
        }
        .onDisappear {
            // Remove notification observers
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidSignIn"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ProfileCompletionStatusChanged"), object: nil)
        }
        .task(id: shouldCheckProfileCompletion) {
            if shouldCheckProfileCompletion && userIsLoggedIn {
                await completionManager.checkProfileCompletion()
                
                // Always check and update tab based on profile completion
                if !completionManager.isProfileComplete {
                    // If profile is incomplete, always go to profile tab
                    selectedTab = 3
                } else if selectedTab == 3 && hasPerformedInitialCheck {
                    // If we're on the profile tab and profile is complete,
                    // redirect to Directory tab, but only if not first launch
                    selectedTab = 0
                }
                
                shouldCheckProfileCompletion = false
            }
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
