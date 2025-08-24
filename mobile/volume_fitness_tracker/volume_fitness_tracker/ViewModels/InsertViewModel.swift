import Foundation
import Combine

@MainActor
class InsertViewModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var exercises: [Exercise] = [Exercise(name: "", weight: 0, reps: 0)]
    @Published var totalVolume: Double = 0
    @Published var showConfirmation: Bool = false
    @Published var isDatePickerExpanded: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let apiClient: APIClientProtocol
    private let userEmail: String
    
    init(userEmail: String, apiClient: APIClientProtocol = APIClient()) {
        self.userEmail = userEmail
        self.apiClient = apiClient
    }
    
    func addExercise() {
        exercises.append(Exercise(name: "", weight: 0, reps: 0))
        calculateTotalVolume()
    }
    
    func removeExercise(at index: Int) {
        guard index < exercises.count else { return }
        exercises.remove(at: index)
        calculateTotalVolume()
    }
    
    func updateExercise(_ exercise: Exercise, at index: Int) {
        guard index < exercises.count else { return }
        exercises[index] = exercise
        calculateTotalVolume()
    }
    
    func calculateTotalVolume() {
        totalVolume = exercises.reduce(0) { $0 + $1.volume }
    }
    
    func validateExercises() -> [String] {
        var errors: [String] = []
        
        for (index, exercise) in exercises.enumerated() {
            let exerciseErrors = Exercise.validate(exercise)
            if !exerciseErrors.isEmpty {
                errors.append("Exercise \(index + 1): \(exerciseErrors.joined(separator: ", "))")
            }
        }
        
        if exercises.isEmpty {
            errors.append("At least one exercise is required")
        }
        
        return errors
    }
    
    func submitWorkout() async {
        let validationErrors = validateExercises()
        guard validationErrors.isEmpty else {
            errorMessage = validationErrors.joined(separator: "\n")
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let workout = WorkoutSubmission(
                user: userEmail,
                date: formatDate(date: date),
                exercises: exercises
            )
            
            let response = try await apiClient.submitWorkout(workout)
            
            successMessage = "Workout submitted successfully! Total Volume: \(String(format: "%.1f", response.totalVolume)) lbs"
            showConfirmation = true
            
            // Reset form after successful submission
            exercises = [Exercise(name: "", weight: 0, reps: 0)]
            calculateTotalVolume()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func toggleDatePicker() {
        isDatePickerExpanded.toggle()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
        showConfirmation = false
    }
}
