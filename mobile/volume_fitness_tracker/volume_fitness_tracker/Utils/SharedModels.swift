import Foundation

// MARK: - Shared Data Models for iOS and Watch Apps
// This file should be shared between iOS and watchOS targets

// MARK: - API Response Models
struct FitnessDataResponse: Codable {
    let user: String
    let exerciseData: [String: ExerciseDetail]
    let totalLifted: Double
    
    enum CodingKeys: String, CodingKey {
        case user
        case exerciseData = "exercise_data"
        case totalLifted = "total_lifted"
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

// MARK: - Exercise Data for Charts
struct ExerciseData: Identifiable {
    let id = UUID()
    let exercise: String
    let value: Int
    
    init(exercise: String, value: Int) {
        self.exercise = exercise
        self.value = value
    }
}
