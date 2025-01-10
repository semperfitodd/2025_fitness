import SwiftUI

struct ContentView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        TabView {
            Text("Hello, \(connectivityManager.userEmail) 0")
                .font(.title)
                .tabItem {
                    Label("Page 0", systemImage: "0.circle")
                }
            
            Text("Hello, \(connectivityManager.userEmail) 1")
                .font(.title)
                .tabItem {
                    Label("Page 1", systemImage: "1.circle")
                }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}
