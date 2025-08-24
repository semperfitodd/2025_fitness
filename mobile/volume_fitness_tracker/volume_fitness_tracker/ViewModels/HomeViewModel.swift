import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var totalLifted: Int = 0
    @Published var yearlyProgressData: [YearlyProgress] = []
    @Published var exerciseData: [ExerciseData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedExercise: String?
    
    private let apiClient: APIClientProtocol
    private let userEmail: String
    
    init(userEmail: String, apiClient: APIClientProtocol = APIClient()) {
        self.userEmail = userEmail
        self.apiClient = apiClient
    }
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.fetchFitnessData(for: userEmail)
            
            // Update total lifted
            totalLifted = Int(response.totalLifted)
            
            // Convert exercise data to our format
            exerciseData = response.exerciseData.map { (exerciseName, detail) in
                ExerciseData(exercise: exerciseName, value: Int(detail.totalVolume))
            }.sorted { $0.value > $1.value }
            
            // Note: Backend doesn't provide yearly progress data in the same format
            // We'll need to calculate this or modify the backend
            yearlyProgressData = []
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func selectExercise(_ exercise: String?) {
        selectedExercise = exercise
    }
    
    func calculateDaysIntoYear() -> Int {
        let currentDate = Date()
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: currentDate))!
        return Calendar.current.dateComponents([.day], from: startOfYear, to: currentDate).day ?? 0
    }
    
    func calculateYearlyGoal() -> Int {
        // Same as React app: 25,000,000 lbs yearly goal
        return 25_000_000
    }
    
    func calculateProgressPercentage() -> Double {
        let goal = Double(calculateYearlyGoal())
        let current = Double(totalLifted)
        return (current / goal) * 100.0
    }
}
