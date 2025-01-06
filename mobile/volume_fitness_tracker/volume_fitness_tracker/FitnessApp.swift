import SwiftUI
import Firebase
import GoogleSignIn

@main
struct FitnessApp: App {
    // Convert @State to @StateObject to handle reference type storage
    @StateObject private var authManager = AuthenticationManager()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.userEmail.isEmpty {
                LoginScreen(onLoginSuccess: { email in
                    authManager.userEmail = email
                })
            } else {
                ContentView(userEmail: authManager.userEmail, onSignOut: authManager.handleSignOut)
            }
        }
    }
}

// Create a separate class to handle authentication state
class AuthenticationManager: ObservableObject {
    @Published var userEmail: String = ""
    
    init() {
        restorePreviousSignIn()
    }
    
    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let error = error {
                print("Error restoring sign-in: \(error.localizedDescription)")
                return
            }
            
            if let user = user,
               let idToken = user.idToken?.tokenString {
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase Auth Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let email = authResult?.user.email {
                        DispatchQueue.main.async {
                            self?.userEmail = email
                        }
                    }
                }
            }
        }
    }
    
    func handleSignOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.userEmail = ""
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
