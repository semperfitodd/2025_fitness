import Foundation
import os.log

enum LogCategory: String {
    case network = "Network"
    case authentication = "Authentication"
    case data = "Data"
    case ui = "UI"
    case error = "Error"
    case performance = "Performance"
}

class Logger {
    static let shared = Logger()
    
    private let networkLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.fitness.app", category: LogCategory.network.rawValue)
    private let authLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.fitness.app", category: LogCategory.authentication.rawValue)
    private let dataLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.fitness.app", category: LogCategory.data.rawValue)
    private let uiLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.fitness.app", category: LogCategory.ui.rawValue)
    private let errorLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.fitness.app", category: LogCategory.error.rawValue)
    private let performanceLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.fitness.app", category: LogCategory.performance.rawValue)
    
    private init() {}
    
    // MARK: - Network Logging
    func logNetworkRequest(_ request: URLRequest, userEmail: String? = nil) {
        let message = """
        🌐 Network Request:
        URL: \(request.url?.absoluteString ?? "Unknown")
        Method: \(request.httpMethod ?? "Unknown")
        Headers: \(request.allHTTPHeaderFields ?? [:])
        User: \(userEmail ?? "Unknown")
        """
        os_log(.info, log: networkLogger, "%{public}@", message)
    }
    
    func logNetworkResponse(_ response: URLResponse?, data: Data?, error: Error?, userEmail: String? = nil) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let message = """
        📡 Network Response:
        Status: \(statusCode)
        Error: \(error?.localizedDescription ?? "None")
        Data Size: \(data?.count ?? 0) bytes
        User: \(userEmail ?? "Unknown")
        """
        os_log(.info, log: networkLogger, "%{public}@", message)
    }
    
    // MARK: - Authentication Logging
    func logAuthenticationEvent(_ event: String, userEmail: String? = nil, success: Bool) {
        let message = """
        🔐 Authentication Event:
        Event: \(event)
        Success: \(success)
        User: \(userEmail ?? "Unknown")
        """
        os_log(.info, log: authLogger, "%{public}@", message)
    }
    
    // MARK: - Data Logging
    func logDataOperation(_ operation: String, userEmail: String? = nil, details: String? = nil) {
        var message = """
        📊 Data Operation:
        Operation: \(operation)
        User: \(userEmail ?? "Unknown")
        """
        
        if let details = details {
            message += "\nDetails: \(details)"
        }
        
        os_log(.info, log: dataLogger, "%{public}@", message)
    }
    
    // MARK: - UI Logging
    func logUIEvent(_ event: String, screen: String, userEmail: String? = nil) {
        let message = """
        🎨 UI Event:
        Event: \(event)
        Screen: \(screen)
        User: \(userEmail ?? "Unknown")
        """
        os_log(.info, log: uiLogger, "%{public}@", message)
    }
    
    // MARK: - Error Logging
    func logError(_ error: Error, context: String, userEmail: String? = nil) {
        let message = """
        ❌ Error:
        Context: \(context)
        Error: \(error.localizedDescription)
        User: \(userEmail ?? "Unknown")
        Stack: \(Thread.callStackSymbols.prefix(5).joined(separator: "\n"))
        """
        os_log(.error, log: errorLogger, "%{public}@", message)
    }
    
    // MARK: - Performance Logging
    func logPerformance(_ operation: String, duration: TimeInterval, userEmail: String? = nil) {
        let message = """
        ⚡ Performance:
        Operation: \(operation)
        Duration: \(String(format: "%.3f", duration))s
        User: \(userEmail ?? "Unknown")
        """
        os_log(.info, log: performanceLogger, "%{public}@", message)
    }
    
    // MARK: - User Action Logging
    func logUserAction(_ action: String, screen: String, userEmail: String? = nil, metadata: [String: Any]? = nil) {
        var message = """
        👤 User Action:
        Action: \(action)
        Screen: \(screen)
        User: \(userEmail ?? "Unknown")
        """
        
        if let metadata = metadata {
            message += "\nMetadata: \(metadata)"
        }
        
        os_log(.info, log: uiLogger, "%{public}@", message)
    }
}

// MARK: - Convenience Extensions
extension Logger {
    static func network(_ message: String) {
        os_log(.info, log: Logger.shared.networkLogger, "%{public}@", message)
    }
    
    static func auth(_ message: String) {
        os_log(.info, log: Logger.shared.authLogger, "%{public}@", message)
    }
    
    static func data(_ message: String) {
        os_log(.info, log: Logger.shared.dataLogger, "%{public}@", message)
    }
    
    static func ui(_ message: String) {
        os_log(.info, log: Logger.shared.uiLogger, "%{public}@", message)
    }
    
    static func error(_ message: String) {
        os_log(.error, log: Logger.shared.errorLogger, "%{public}@", message)
    }
    
    static func performance(_ message: String) {
        os_log(.info, log: Logger.shared.performanceLogger, "%{public}@", message)
    }
}
