import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileCompletionManager: ObservableObject {
    static let shared = ProfileCompletionManager()
    
    @Published var isProfileComplete = false {
        didSet {
            if oldValue != isProfileComplete {
                // Post notification when profile completion status changes
                NotificationCenter.default.post(
                    name: NSNotification.Name("ProfileCompletionStatusChanged"),
                    object: nil,
                    userInfo: ["isComplete": isProfileComplete]
                )
            }
        }
    }
    @Published var isLoading = false
    @Published var profileCompletionMessage: String?
    
    private init() {
        checkProfileCompletion()
    }
    
    func checkProfileCompletion() {
        guard let user = Auth.auth().currentUser else {
            profileCompletionMessage = "Please sign in to complete your profile"
            isProfileComplete = false
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("entrepreneurs").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                self.profileCompletionMessage = "Unable to check profile status"
                self.isProfileComplete = false
                return
            }
            
            guard let data = snapshot?.data() else {
                self.profileCompletionMessage = "Complete your profile to showcase your business"
                self.isProfileComplete = false
                return
            }
            
            // Check if profile has basic information
            let hasName = (data["fullName"] as? String)?.isEmpty == false
            let hasBio = (data["bioDescr"] as? String)?.isEmpty == false
            let hasProfileImage = (data["profileUrl"] as? String)?.isEmpty == false
            let hasCompanies = (data["companyIds"] as? [String])?.isEmpty == false
            
            if hasName && (hasBio || hasProfileImage) && hasCompanies {
                // Profile is reasonably complete
                self.isProfileComplete = true
                self.profileCompletionMessage = nil
            } else {
                // Profile is incomplete
                self.isProfileComplete = false
                
                // Create a specific message based on what's missing
                if !hasName {
                    self.profileCompletionMessage = "Add your name to complete your profile"
                } else if !hasProfileImage {
                    self.profileCompletionMessage = "Add a profile photo to showcase yourself"
                } else if !hasBio {
                    self.profileCompletionMessage = "Tell your story to connect with others"
                } else if !hasCompanies {
                    self.profileCompletionMessage = "Add your business to the directory"
                } else {
                    self.profileCompletionMessage = "Complete your profile to showcase your business"
                }
            }
        }
    }
} 