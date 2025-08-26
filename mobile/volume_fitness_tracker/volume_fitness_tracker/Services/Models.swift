import Foundation

// MARK: - Core Data Models
struct YearlyProgress: Identifiable, Codable {
    let id = UUID()
    let index: Int
    let month: String
    let lifted: Int
    
    init(index: Int, month: String, lifted: Int) {
        self.index = index
        self.month = month
        self.lifted = lifted
    }
}

// Note: ExerciseData, FitnessDataResponse, and ExerciseDetail are now defined in SharedModels.swift

// MARK: - Workout Models
struct Exercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var weight: Double
    var reps: Int
    
    init(name: String, weight: Double, reps: Int) {
        self.name = name
        self.weight = weight
        self.reps = reps
    }
    
    var volume: Double {
        weight * Double(reps)
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        weight > 0 &&
        reps > 0 &&
        weight <= 10000 && // Reasonable max weight
        reps <= 1000 // Reasonable max reps
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "weight": weight,
            "reps": reps
        ]
    }
}

struct WorkoutSubmission: Codable {
    let user: String
    let date: String
    let exercises: [ExerciseSubmission]
    
    struct ExerciseSubmission: Codable {
        let name: String
        let weight: Double
        let reps: Int
    }
    
    init(user: String, date: String, exercises: [Exercise]) {
        self.user = user
        self.date = date
        self.exercises = exercises.map { exercise in
            ExerciseSubmission(name: exercise.name, weight: exercise.weight, reps: exercise.reps)
        }
    }
}

struct WorkoutPlanResponse: Codable {
    let workoutPlan: String
    
    enum CodingKeys: String, CodingKey {
        case workoutPlan = "workout_plan"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle the actual Bedrock response format
        if let workoutPlanArray = try? container.decode([BedrockTextBlock].self, forKey: .workoutPlan) {
            // Extract text from the first text block
            self.workoutPlan = workoutPlanArray.first?.text ?? "No workout plan generated"
        } else if let workoutPlanString = try? container.decode(String.self, forKey: .workoutPlan) {
            // Handle direct string format (fallback)
            self.workoutPlan = workoutPlanString
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .workoutPlan,
                in: container,
                debugDescription: "Expected either array of text blocks or string"
            )
        }
    }
    
    init(workoutPlan: String) {
        self.workoutPlan = workoutPlan
    }
}

// Helper struct for Bedrock response format
struct BedrockTextBlock: Codable {
    let type: String
    let text: String
}

// MARK: - Error Models
enum FitnessError: LocalizedError {
    case networkError(String)
    case invalidData(String)
    case authenticationError(String)
    case serverError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .invalidData(let message):
            return "Invalid Data: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
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

// MARK: - Validation
extension Exercise {
    static func validate(_ exercise: Exercise) -> [String] {
        var errors: [String] = []
        
        if exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Exercise name is required")
        }
        
        if exercise.weight <= 0 {
            errors.append("Weight must be greater than 0")
        }
        
        if exercise.weight > 10000 {
            errors.append("Weight seems unrealistic (max 10,000 lbs)")
        }
        
        if exercise.reps <= 0 {
            errors.append("Reps must be greater than 0")
        }
        
        if exercise.reps > 1000 {
            errors.append("Reps seem unrealistic (max 1,000)")
        }
        
        return errors
    }
}
