import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    @Published var userEmail: String = "Guest"

    private override init() {
        super.init()

        #if os(iOS)
        guard WCSession.isSupported() else {
            return
        }
        #endif

        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func updateEmail(_ email: String) {
        guard WCSession.default.activationState == .activated else {
            return
        }

        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #endif

        WCSession.default.sendMessage(["email": email], replyHandler: nil) { error in
            print("Error sending email to WatchOS: \(error.localizedDescription)")
        }
    }

    func retryFetchingEmail() {
        // Try fetching email from application context first
        if let email = WCSession.default.receivedApplicationContext["email"] as? String {
            self.userEmail = email
            print("Email fetched from application context during retry: \(email)")
        } else {
            // If no email in application context, send a request message
            WCSession.default.sendMessage(["requestEmail": true], replyHandler: { response in
                if let email = response["email"] as? String {
                    DispatchQueue.main.async {
                        self.userEmail = email
                        print("Email received during retry: \(email)")
                    }
                }
            }) { error in
                print("Error requesting email during retry: \(error.localizedDescription)")
            }
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activation did complete with state: \(activationState.rawValue)")
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let email = message["email"] as? String {
                self.userEmail = email
                print("Updated userEmail to: \(email)")
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            if let email = applicationContext["email"] as? String {
                self.userEmail = email
                print("Email updated from application context: \(email)")
            }
        }
    }
}
