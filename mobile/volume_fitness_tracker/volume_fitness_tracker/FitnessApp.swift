import SwiftUI
import Firebase
import GoogleSignIn
import WatchConnectivity

@main
struct FitnessApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.userEmail.isEmpty {
                LoginScreen(onLoginSuccess: { email in
                    authManager.userEmail = email
                    connectivityManager.updateEmail(email)
                })
            } else {
                ContentView(userEmail: authManager.userEmail, onSignOut: {
                    authManager.handleSignOut()
                })
            }
        }
    }
}

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
                            WatchConnectivityManager.shared.updateEmail(email)
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
            WatchConnectivityManager.shared.updateEmail("Guest")
            DispatchQueue.main.async {
                self.userEmail = ""
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
