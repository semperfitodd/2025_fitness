import SwiftUI
import Firebase
import GoogleSignIn

@main
struct FitnessApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.userEmail.isEmpty {
                LoginScreen(onLoginSuccess: { email, name in
                    authManager.userEmail = email
                    authManager.userName = name ?? ""
                })
            } else {
                ContentView(userEmail: authManager.userEmail, userName: authManager.userName, onSignOut: {
                    authManager.handleSignOut()
                })
            }
        }
    }
}

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var userEmail: String = ""
    @Published var userName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let logger = Logger.shared
    
    init() {
        restorePreviousSignIn()
    }
    
    private func restorePreviousSignIn() {
        isLoading = true
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            Task { @MainActor in
                self?.isLoading = false
                
                if let error = error {
                    self?.logger.logError(error, context: "Restore Previous Sign In")
                    self?.errorMessage = "Failed to restore sign-in: \(error.localizedDescription)"
                    return
                }
                
                if let user = user,
                   let idToken = user.idToken?.tokenString {
                    self?.logger.logAuthenticationEvent("Restore Previous Sign In", userEmail: user.profile?.email, success: true)
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: user.accessToken.tokenString
                    )
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        Task { @MainActor in
                            if let error = error {
                                self?.logger.logError(error, context: "Firebase Auth Restore")
                                self?.errorMessage = "Firebase authentication failed: \(error.localizedDescription)"
                                return
                            }
                            
                            if let email = authResult?.user.email {
                                self?.userEmail = email
                                // Extract first name from display name
                                if let displayName = authResult?.user.displayName {
                                    let components = displayName.components(separatedBy: " ")
                                    self?.userName = components.first ?? ""
                                }
                                self?.logger.logAuthenticationEvent("Firebase Auth Success", userEmail: email, success: true)
                            }
                        }
                    }
                } else {
                    self?.logger.logAuthenticationEvent("No Previous Sign In", userEmail: nil, success: false)
                }
            }
        }
    }
    
    func handleSignOut() {
        isLoading = true
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            userEmail = ""
            userName = ""
            logger.logAuthenticationEvent("Sign Out", userEmail: nil, success: true)
            
        } catch {
            logger.logError(error, context: "Sign Out")
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
