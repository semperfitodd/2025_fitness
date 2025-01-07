import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Hello, Todd 0")
                .font(.title)
                .tabItem {
                    Label("Page 0", systemImage: "0.circle")
                }
            
            Text("Hello, Todd 1")
                .font(.title)
                .tabItem {
                    Label("Page 1", systemImage: "1.circle")
                }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

#Preview {
    ContentView()
}
