import Foundation
import Combine

@MainActor
class GenerateWorkoutViewModel: ObservableObject {
    @Published var workoutPlan: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasGeneratedWorkout: Bool = false
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func generateWorkout() async {
        isLoading = true
        errorMessage = nil
        workoutPlan = ""
        
        do {
            let response = try await apiClient.generateWorkout()
            workoutPlan = response.workoutPlan
            hasGeneratedWorkout = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearWorkout() {
        workoutPlan = ""
        hasGeneratedWorkout = false
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}
