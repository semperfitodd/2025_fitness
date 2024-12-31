import Foundation

struct YearlyProgress: Identifiable {
    let id = UUID()
    let index: Int
    let month: String
    let lifted: Int
}

struct ExerciseData: Identifiable {
    let id = UUID()
    let exercise: String
    let value: Int
}
