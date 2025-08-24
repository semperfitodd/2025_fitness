import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct LoginScreen: View {
    @State private var isAuthenticated = false
    @State private var userEmail: String?
    var onLoginSuccess: (String) -> Void

    var body: some View {
        if isAuthenticated, let email = userEmail {
            DispatchQueue.main.async {
                onLoginSuccess(email)
            }
            return AnyView(EmptyView())
        } else {
            return AnyView(
                VStack {
                    Text("Sign in to Fitness App")
                        .font(.title)
                        .padding()
                    
                    GoogleSignInButton(action: signInWithGoogle)
                        .padding()
                        .frame(maxWidth: 280)
                }
                .padding()
            )
        }
    }

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signResult, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = signResult?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth Error: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    userEmail = authResult?.user.email
                    isAuthenticated = true
                }
            }
        }
    }
}
