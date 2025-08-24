import Foundation

// MARK: - Shared Data Models
struct FitnessDataResponse: Codable {
    let totalLifted: Double
    let exerciseData: [String: ExerciseDetail]
    
    enum CodingKeys: String, CodingKey {
        case totalLifted = "total_lifted"
        case exerciseData = "exercise_data"
    }
}

struct ExerciseDetail: Codable {
    let totalVolume: Double
    let totalReps: Double
    
    enum CodingKeys: String, CodingKey {
        case totalVolume = "total_volume"
        case totalReps = "total_reps"
    }
}

struct ExerciseData: Identifiable, Codable {
    let id = UUID()
    let exercise: String
    let value: Int
    
    init(exercise: String, value: Int) {
        self.exercise = exercise
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case exercise, value
        // id is not included in coding keys since it's auto-generated
    }
}

// MARK: - Watch App Constants
struct WatchConstants {
    static let yearlyGoalLbs: Int = 25_000_000
    static let daysInYear: Int = 365
    
    struct UI {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 8
    }
    
    struct Formatting {
        static let millionThreshold: Double = 1_000_000
        static let thousandThreshold: Double = 1_000
    }
}

// MARK: - Watch App Error Types
enum WatchAPIError: LocalizedError {
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
