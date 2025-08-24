import SwiftUI

struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoading ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isLoading)
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView("Fetching your records...")
        LoadingButton(title: "Submit", isLoading: true) {}
        LoadingButton(title: "Submit", isLoading: false) {}
    }
}
