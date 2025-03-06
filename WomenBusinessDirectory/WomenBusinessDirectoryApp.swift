//
//  WomenBusinessDirectoryApp.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import Firebase
import Alamofire
import AlamofireImage

// Create a shared session that can be accessed throughout the app
class NetworkManager {
    static let shared = NetworkManager()
    
    let session: Session
    
    private init() {
        // Configure Alamofire for image caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 30 seconds timeout
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        // Set up a custom cache configuration
        URLCache.shared = URLCache(
            memoryCapacity: 100_000_000, // 100 MB memory cache
            diskCapacity: 500_000_000,   // 500 MB disk cache
            diskPath: nil
        )
        
        configuration.urlCache = URLCache.shared
        
        // Create the session with standard Alamofire (not AlamofireDynamic)
        self.session = Session(configuration: configuration)
        
        // Print session info for debugging
        print("Alamofire Session initialized with configuration: \(configuration)")
    }
}

@main
struct WomenBusinessDirectoryApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        SplashScreen()
          .environment(\.companyManager, RealCompanyManager.shared)
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // Initialize NetworkManager to set up caching
    print("Setting up image caching with Alamofire...")
    _ = NetworkManager.shared
    print("URLCache configured with \(URLCache.shared.memoryCapacity / 1_000_000) MB memory capacity")
    
    return true
  }
}

struct CompanyManagerKey: EnvironmentKey {
  static let defaultValue: CompanyManager = RealCompanyManager.shared
}

extension EnvironmentValues {
  var companyManager: CompanyManager {
    get { self[CompanyManagerKey.self] }
    set { self[CompanyManagerKey.self] = newValue }
  }
}
