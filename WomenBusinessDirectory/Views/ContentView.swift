//
//  ContentView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
    Group {
      TabView {
        DirectoryListView(viewModel: DirectoryListViewModel())
          .tabItem {
            Label("Directories", systemImage: "newspaper")
          }
        
        EventsListView()
          .tabItem {
            Label("Events", systemImage: "list.bullet.rectangle")
          }
        
        FavoritesListView()
          .tabItem {
            Label("Favourites", systemImage: "star.square")
          }
        
        RootView()
          .tabItem {
            Label("Profile", systemImage: "person.fill")
          }
      }
    }
  }
}

#Preview {
    ContentView()
}
