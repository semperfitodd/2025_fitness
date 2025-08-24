import SwiftUI

@main
struct volume_fitness_tracker_watch_Watch_AppApp: App {
    init() {
        print("⌚ Watch App: INIT - App is starting")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("⌚ Watch App: App started")
                }
        }
    }
}
