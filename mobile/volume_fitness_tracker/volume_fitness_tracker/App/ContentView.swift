import SwiftUI

struct ContentView: View {
    let userEmail: String
    var onSignOut: () -> Void

    var body: some View {
        TabView {
            HomeScreen(userEmail: userEmail)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            InsertScreen(userEmail: userEmail)
                .tabItem {
                    Label("Add Workout", systemImage: "plus.circle.fill")
                }
                .tag(1)

            GenerateWorkoutScreen(userEmail: userEmail)
                .tabItem {
                    Label("Generate", systemImage: "dumbbell.fill")
                }
                .tag(2)

            SettingsScreen(onSignOut: onSignOut)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView(userEmail: "test@example.com") {
        print("Sign out tapped")
    }
}
