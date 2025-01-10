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
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let email = message["email"] as? String {
                self.userEmail = email
            }
        }
    }
}
