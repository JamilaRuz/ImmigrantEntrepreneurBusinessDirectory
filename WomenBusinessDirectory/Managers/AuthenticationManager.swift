import FirebaseAuth
import FirebaseFirestore

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private let db = Firestore.firestore()

    private init() {}

    @discardableResult
    func signIn(email: String, password: String) async throws -> Bool {
        // Attempt to sign in with Firebase Authentication
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)

        // Check if the email exists in the Firestore database
        let querySnapshot = try await db.collection("entrepreneurs")
            .whereField("email", isEqualTo: email)
            .getDocuments()

        // Return true if the email exists in Firestore
        return !querySnapshot.isEmpty
    }
}
