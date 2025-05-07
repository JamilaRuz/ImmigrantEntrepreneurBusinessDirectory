import SwiftUI
import FirebaseAuth

struct ProfileCompletionModifier: ViewModifier {
    @ObservedObject var completionManager = ProfileCompletionManager.shared
    var action: (() -> Void)?
    var isOwnProfile: Bool
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isOwnProfile, let message = completionManager.profileCompletionMessage, !completionManager.isProfileComplete {
                ProfileCompletionBanner(message: message, action: action)
                    .animation(.easeInOut, value: message)
                    .zIndex(50) // High zIndex but lower than navigation bar
            }
            
            content
        }
        .onAppear {
            if isOwnProfile {
                Task {
                    await completionManager.checkProfileCompletion()
                }
            }
        }
    }
}

extension View {
    func withProfileCompletionBanner(isOwnProfile: Bool = true, action: (() -> Void)? = nil) -> some View {
        self.modifier(ProfileCompletionModifier(action: action, isOwnProfile: isOwnProfile))
    }
} 