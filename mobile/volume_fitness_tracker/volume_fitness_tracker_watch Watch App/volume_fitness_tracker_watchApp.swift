import SwiftUI

@main
struct volume_fitness_tracker_watch_Watch_AppApp: App {
    init() {
        print("\(SharedConstants.Logging.watchPrefix): INIT - App is starting")
        
        // Initialize Shared CloudKit Data Manager
        _ = SharedCloudKitManager.shared
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("\(SharedConstants.Logging.watchPrefix): App started")
                }
        }
    }
}
