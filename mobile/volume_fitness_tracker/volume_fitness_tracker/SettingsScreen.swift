import SwiftUI
import FirebaseAuth

struct SettingsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSigningOut: Bool = false
    var onSignOut: () -> Void

    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .padding()

            Button(action: handleSignOut) {
                Text(isSigningOut ? "Signing Out..." : "Sign Out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func handleSignOut() {
        guard !isSigningOut else { return }
        isSigningOut = true

        do {
            try Auth.auth().signOut()
            isSigningOut = false
            onSignOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            isSigningOut = false
        }
    }
}
