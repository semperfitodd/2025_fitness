import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    var onSignOut: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: Constants.UI.padding) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Button(action: {
                    viewModel.signOut(onSuccess: onSignOut)
                }) {
                    Text(viewModel.isSigningOut ? "Signing Out..." : "Sign Out")
                }
                .standardButton(color: .red)
                .disabled(viewModel.isSigningOut)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
