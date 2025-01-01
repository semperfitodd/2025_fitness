import SwiftUI
import Firebase

@main
struct FitnessApp: App {
    init() {
        FirebaseApp.configure()
    }

    @State private var userEmail: String = ""

    var body: some Scene {
        WindowGroup {
            LoginScreen(onLoginSuccess: { email in
                userEmail = email
            })
            .overlay(
                userEmail.isEmpty ? nil : AnyView(ContentView(userEmail: userEmail))
            )
        }
    }
}
