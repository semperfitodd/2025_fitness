import SwiftUI

struct ContentView: View {
    let userEmail: String
    var onSignOut: () -> Void

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

            GenerateWorkoutScreen(userEmail: userEmail)
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
                .tag(2)

            SettingsScreen(onSignOut: onSignOut)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}
