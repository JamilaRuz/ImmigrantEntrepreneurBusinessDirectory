////
////  ContentView.swift
////  WomenBusinessDirectory
////
////  Created by Jamila Ruzimetova on 4/12/24.
////
//
//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
////  @EnvironmentObject var viewModel: AuthViewModel
//  @State var entrepreneur: Entrepreneur?
//  
//  var body: some View {
//    Group {
////      if viewModel.userSession != nil {
////        if let entrepreneur = entrepreneur {
////        ProfileView(viewModel: viewModel)
////          .environmentObject(viewModel)
//          
////          TabView {
////            DirectoryListView(entrepreneur: entrepreneur)
////              .tabItem {
////                Label("Directories", systemImage: "newspaper")
////              }
////            
////            EventsListView()
////              .tabItem {
////                Label("Events", systemImage: "list.bullet.rectangle")
////              }
////            
////            FavoritesListView()
////              .tabItem {
////                Label("Favourites", systemImage: "star.square")
////              }
////          }
////        }
////      } else {
////        LoginView()
////      }
//    }
//  }
//}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: Company.self, inMemory: true)
//}
