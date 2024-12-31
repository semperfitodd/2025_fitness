import SwiftUI
import Firebase

@main
struct FitnessApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginScreen()
        }
    }
}
