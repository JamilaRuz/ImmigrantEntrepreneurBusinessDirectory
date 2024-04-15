//
//  ContentView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DirectoryListView()
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
//        .onAppear() {
//            UITabBar.appearance().backgroundColor = UIColor(.lightPink)
//        }
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView()
        .modelContainer(for: Company.self, inMemory: true)
}
