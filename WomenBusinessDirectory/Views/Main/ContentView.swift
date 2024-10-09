//
//  ContentView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showSignInView = true
    @StateObject private var directoryListViewModel = DirectoryListViewModel()

    var body: some View {
        Group {
            if showSignInView {
                AuthenticationView(showSignInView: $showSignInView)
            } else {
                MainTabView(
                    showSignInView: $showSignInView,
                    directoryListViewModel: directoryListViewModel
                )
            }
        }
    }
}

struct MainTabView: View {
    @Binding var showSignInView: Bool
    @ObservedObject var directoryListViewModel: DirectoryListViewModel
    
    var body: some View {
        TabView {
            DirectoryListView(viewModel: directoryListViewModel, showSignInView: $showSignInView)
                .tabItem {
                    Label("Directories", systemImage: "newspaper")
                }
            
            FavoritesListView()
                .tabItem {
                    Label("Favourites", systemImage: "star.square")
                }
            
            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
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
