import SwiftUI
import FirebaseAuth
import GoogleSignIn
import OSLog

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isSigningOut = false
    @Published var errorMessage: String?
    
    private let logger = Logger.shared
    
    func signOut(onSuccess: @escaping () -> Void) {
        guard !isSigningOut else { return }
        
        isSigningOut = true
        logger.logAuthenticationEvent("User initiated sign out", success: true)
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            // Clear user data from CloudKit (shared with watch app)
            CloudKitDataManager.shared.clearUserData()
            
            isSigningOut = false
            logger.logAuthenticationEvent("User successfully signed out", success: true)
            onSuccess()
        } catch {
            isSigningOut = false
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            logger.logError(error, context: "Sign out operation")
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
