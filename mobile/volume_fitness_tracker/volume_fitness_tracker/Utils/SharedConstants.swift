import Foundation

// MARK: - Shared Constants for iOS and Watch Apps
// This file should be shared between iOS and watchOS targets

struct SharedConstants {
    // Fitness Goals
    static let yearlyGoalLbs: Int = 25_000_000
    static let daysInYear: Int = 365
    
    // CloudKit Configuration
    static let cloudKitContainerIdentifier = "iCloud.com.bernsonfamily.volume-fitness-tracker"
    static let cloudKitRecordType = "UserData"
    static let cloudKitRecordName = "currentUser"
    
    // UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusMedium: CGFloat = 10
        static let padding: CGFloat = 16
        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 12
    }
    
    // Chart Constants
    struct Chart {
        static let pieChartHoleRadius: Double = 0.6
        static let pieChartAnimationDuration: Double = 1.5
        static let pieChartSelectionShift: Double = 15
    }
    
    // Number Formatting
    struct Formatting {
        static let millionThreshold: Double = 1_000_000
        static let thousandThreshold: Double = 1_000
    }
    
    // Logging Prefixes
    struct Logging {
        static let iOSPrefix = "📱 iOS"
        static let watchPrefix = "⌚ Watch"
        static let cloudKitPrefix = "☁️ CloudKit"
    }
}

// MARK: - Shared Error Types
enum SharedAPIError: LocalizedError {
    case invalidURL
    case serializationError(Error)
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case noData
    case invalidJSON
    case parsingError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .serializationError(let error):
            return "Failed to serialize request: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid HTTP response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .noData:
            return "No data received"
        case .invalidJSON:
            return "Invalid JSON response"
        case .parsingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
