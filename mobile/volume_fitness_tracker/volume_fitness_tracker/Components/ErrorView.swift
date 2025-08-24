import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    init(message: String, onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                if let onDismiss = onDismiss {
                    Button("Dismiss") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                if let onRetry = onRetry {
                    Button("Retry") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

struct ErrorAlert: ViewModifier {
    let errorMessage: String?
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    onDismiss()
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
    }
}

extension View {
    func errorAlert(errorMessage: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ErrorAlert(errorMessage: errorMessage, onDismiss: onDismiss))
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorView(
            message: "Failed to fetch data. Please check your connection and try again.",
            onRetry: {},
            onDismiss: {}
        )
        
        ErrorView(
            message: "Network error occurred",
            onRetry: {}
        )
        
        ErrorView(
            message: "Something went wrong"
        )
    }
}
