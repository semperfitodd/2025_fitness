import SwiftUI

struct ContentView: View {
    let userEmail: String

    var body: some View {
        TabView {
            HomeScreen(userEmail: userEmail)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            InsertScreen(userEmail: userEmail)
                .tabItem {
                    Label("Insert", systemImage: "plus.circle")
                }
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}
