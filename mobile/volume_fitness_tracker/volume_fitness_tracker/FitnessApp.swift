import SwiftUI
import Firebase

@main
struct FitnessApp: App {
    init() {
        FirebaseApp.configure()
        checkAuthState()
    }

    @State private var userEmail: String = ""

    var body: some Scene {
        WindowGroup {
            if userEmail.isEmpty {
                LoginScreen(onLoginSuccess: { email in
                    userEmail = email
                })
            } else {
                ContentView(userEmail: userEmail, onSignOut: handleSignOut)
            }
        }
    }

    private func handleSignOut() {
        userEmail = ""
    }

    private func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            userEmail = currentUser.email ?? ""
        }
    }
}
