//
//  ContentView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @State var entrepreneur: Entrepreneur?
  
  var body: some View {
    TabView {
      DirectoryListView(entrepreneur: entrepreneur)
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
    }
  }
}

#Preview {
    ContentView()
        .modelContainer(for: Company.self, inMemory: true)
}
