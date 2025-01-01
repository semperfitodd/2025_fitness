import SwiftUI

struct InsertScreen: View {
    let userEmail: String

    var body: some View {
        VStack {
            Text("Hello \(userEmail)")
                .font(.title)
                .padding()
        }
    }
}
