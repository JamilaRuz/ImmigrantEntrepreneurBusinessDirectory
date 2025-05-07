import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

enum FirebaseErrorCode: String {
    // Auth error codes
    case emailAlreadyInUse = "ERROR_EMAIL_ALREADY_IN_USE"
    case invalidEmail = "ERROR_INVALID_EMAIL"
    case wrongPassword = "ERROR_WRONG_PASSWORD"
    case userNotFound = "ERROR_USER_NOT_FOUND"
    case userDisabled = "ERROR_USER_DISABLED"
    case weakPassword = "ERROR_WEAK_PASSWORD"
    case networkRequestFailed = "ERROR_NETWORK_REQUEST_FAILED"
    case networkError = "ERROR_NETWORK_ERROR"
    case tooManyRequests = "ERROR_TOO_MANY_REQUESTS"
    case requiresRecentLogin = "ERROR_REQUIRES_RECENT_LOGIN"
    
    // Firestore error codes
    case permissionDenied = "PERMISSION_DENIED"
    case unavailable = "UNAVAILABLE"
    case notFound = "NOT_FOUND"
    case cancelled = "CANCELLED"
    case deadlineExceeded = "DEADLINE_EXCEEDED"
    case dataLoss = "DATA_LOSS"
    
    // Custom error codes
    case imageUploadFailed = "IMAGE_UPLOAD_FAILED"
    case invalidData = "INVALID_DATA"
    case unknown = "UNKNOWN_ERROR"
}

struct FirebaseErrorHandler {
    
    static func handleError(_ error: Error) -> String {
        var errorMessage = "An unexpected error occurred. Please try again."
        
        // Handle email verification error
        let nsError = error as NSError
        if nsError.domain == "EmailVerificationError" && nsError.code == 1001 {
            return nsError.localizedDescription + "\n\nWould you like to resend the verification email?"
        }
        
        // Handle Auth Errors
        if let authError = error as? AuthErrorCode {
            errorMessage = getAuthErrorMessage(authError)
        }
        // Handle Firestore Errors
        else if let firestoreError = error as NSError?, firestoreError.domain == FirestoreErrorDomain {
            errorMessage = getFirestoreErrorMessage(firestoreError)
        }
        // Handle Storage Errors
        else if let storageError = error as NSError?, storageError.domain == StorageErrorDomain {
            errorMessage = getStorageErrorMessage(storageError)
        }
        // Handle NSError with Firebase error codes
        else if let nsError = error as NSError? {
            // Try to extract Firebase error code from error
            if let errorCode = nsError.userInfo["FIRAuthErrorUserInfoNameKey"] as? String {
                errorMessage = getErrorMessageFromCode(errorCode)
            } else {
                // Check if it's a network error
                if nsError.domain == NSURLErrorDomain {
                    errorMessage = "Network connection problem. Please check your internet connection and try again."
                }
            }
        }
        
        // Log the error for debugging/analytics
        print("Firebase Error: \(error.localizedDescription)")
        
        return errorMessage
    }
    
    private static func getAuthErrorMessage(_ error: AuthErrorCode) -> String {
        switch error.code {
        case .emailAlreadyInUse:
            return "This email is already in use. Please try another one or sign in."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword:
            return "Incorrect password. Please try again or reset your password."
        case .userNotFound:
            return "Account not found. Please check your email or create an account."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        case .weakPassword:
            return "Password is too weak. Please use a stronger password."
        case .networkError:
            return "Network error. Please check your internet connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        case .requiresRecentLogin:
            return "This action requires you to sign in again. Please sign out and sign back in."
        default:
            return "Authentication error. Please try again."
        }
    }
    
    private static func getFirestoreErrorMessage(_ error: NSError) -> String {
        switch error.code {
        case FirestoreErrorCode.permissionDenied.rawValue:
            return "You don't have permission to perform this action."
        case FirestoreErrorCode.unavailable.rawValue:
            return "The service is currently unavailable. Please try again later."
        case FirestoreErrorCode.notFound.rawValue:
            return "The requested information could not be found."
        case FirestoreErrorCode.cancelled.rawValue:
            return "The operation was cancelled."
        case FirestoreErrorCode.dataLoss.rawValue:
            return "Data loss error. Please contact support."
        case FirestoreErrorCode.deadlineExceeded.rawValue:
            return "Operation timeout. Please try again."
        default:
            return "Database error. Please try again."
        }
    }
    
    private static func getStorageErrorMessage(_ error: NSError) -> String {
        switch error.code {
        case StorageErrorCode.objectNotFound.rawValue:
            return "The requested file could not be found."
        case StorageErrorCode.unauthorized.rawValue:
            return "You don't have permission to access this file."
        case StorageErrorCode.cancelled.rawValue:
            return "The upload was cancelled."
        case StorageErrorCode.quotaExceeded.rawValue:
            return "Storage quota exceeded. Please contact support."
        case StorageErrorCode.unauthenticated.rawValue:
            return "Please sign in to upload files."
        default:
            return "File storage error. Please try again."
        }
    }
    
    private static func getErrorMessageFromCode(_ code: String) -> String {
        guard let errorCode = FirebaseErrorCode(rawValue: code) else {
            return "An unexpected error occurred. Please try again."
        }
        
        switch errorCode {
        case .emailAlreadyInUse:
            return "This email is already in use. Please try another one or sign in."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword:
            return "Incorrect password. Please try again or reset your password."
        case .userNotFound:
            return "Account not found. Please check your email or create an account."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        case .weakPassword:
            return "Password is too weak. Please use a stronger password."
        case .networkRequestFailed, .networkError:
            return "Network error. Please check your internet connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        case .requiresRecentLogin:
            return "This action requires you to sign in again. Please sign out and sign back in."
        case .permissionDenied:
            return "You don't have permission to perform this action."
        case .unavailable:
            return "The service is currently unavailable. Please try again later."
        case .notFound:
            return "The requested information could not be found."
        case .cancelled:
            return "The operation was cancelled."
        case .deadlineExceeded:
            return "Operation timeout. Please try again."
        case .dataLoss:
            return "Data loss error. Please contact support."
        case .imageUploadFailed:
            return "Failed to upload image. Please try again."
        case .invalidData:
            return "Invalid data. Please check your input and try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
} 